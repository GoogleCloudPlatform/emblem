data "google_project" "target_project" {
  project_id = var.project_id
}

# Create this topic to emit writes to Artifact Registry as events.
# https://cloud.google.com/artifact-registry/docs/configure-notifications#topic
resource "google_pubsub_topic" "gcr" {
  name     = "gcr"
  project  = var.project_id
  provider = google
}

# Across Cloud Build jobs we need to publish to several topics.
# TODO: Break up this permission to granular topics via gcloud_pubsub_topic_iam_member.
resource "google_project_iam_member" "pubsub_publisher_iam_member" {
  project  = var.project_id
  provider = google
  for_each = toset(local.pubsub_iam_roles_list)
  role     = each.key
  member   = "serviceAccount:${data.google_project.target_project.number}@cloudbuild.gserviceaccount.com"

  depends_on = [
    google_project_service.emblem_ops_services
  ]
}

#####################
# Container Hosting #
#####################

resource "google_artifact_registry_repository" "website_docker" {
  format        = "DOCKER"
  location      = var.region
  repository_id = "website"
  project       = var.project_id
  provider      = google-beta

  depends_on = [
    # Need to ensure Artifact Registry API is enabled first.
    time_sleep.wait_for_artifactregistry
  ]
}

resource "google_artifact_registry_repository" "api_docker" {
  format        = "DOCKER"
  location      = var.region
  repository_id = "content-api"
  project       = var.project_id
  provider      = google-beta

  depends_on = [
    # Need to ensure Artifact Registry API is enabled first.
    time_sleep.wait_for_artifactregistry
  ]
}

resource "google_artifact_registry_repository" "e2e_testing_docker" {
  format        = "DOCKER"
  location      = var.region
  repository_id = "e2e-testing"
  project       = var.project_id
  provider      = google-beta

  depends_on = [
    time_sleep.wait_for_artifactregistry
  ]
}

###########################
# End-user Authentication #
###########################

# This section provides common infrastructure for Google Sign-in OAuth.
#
# These secrets are referenced as part of the Cloud Run Website service.
# If the OAuth setup is not completed the lack of values indicate the site
# should operate in read-only mode.
#
# See https://github.com/GoogleCloudPlatform/blob/main/scripts/configure_auth.sh
# to setup authentication if your Emblem instance is missing secret versions.

resource "google_secret_manager_secret" "oauth_client_id" {
  project   = var.project_id
  secret_id = "client_id_secret"
  replication {
    automatic = "true"
  }

  # Adding depends_on prevents race conditions in API enablement
  # This is a workaround for:
  #   https://github.com/hashicorp/terraform-provider-google/issues/10682
  depends_on = [google_project_service.emblem_ops_services]
}

resource "google_secret_manager_secret" "oauth_client_secret" {
  project   = var.project_id
  secret_id = "client_secret_secret"
  replication {
    automatic = "true"
  }

  # Adding depends_on prevents race conditions in API enablement
  # This is a workaround for:
  #   https://github.com/hashicorp/terraform-provider-google/issues/10682
  depends_on = [google_project_service.emblem_ops_services]
}

######################
# Nightly Operations #
######################

# This topic is published to once a day via Cloud Scheduler
# Used by:
# - google_cloudbuild_trigger.e2e_nightly_tests
resource "google_pubsub_topic" "nightly" {
  name    = "nightly"
  project = var.project_id
}

resource "google_cloud_scheduler_job" "nightly_schedule" {
  project     = var.project_id
  name        = "nightly"
  description = "This job runs nightly operations."
  region      = var.region
  schedule    = "0 2 * * *"
  pubsub_target {
    topic_name = google_pubsub_topic.nightly.id
    data       = base64encode("not empty")
  }
  depends_on = [
    google_pubsub_topic.nightly,
    time_sleep.wait_for_artifactregistry
  ]
}
