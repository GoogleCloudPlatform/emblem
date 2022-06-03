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

resource "google_project_iam_member" "pubsub_publisher_iam_member" {
  project  = var.project_id
  provider = google
  role     = "roles/pubsub.publisher"
  member   = "serviceAccount:${data.google_project.target_project.number}@cloudbuild.gserviceaccount.com"

  depends_on = [
    google_project_service.emblem_ops_services
  ]
}

# Container Hosting

# Artifact Registry API enablement is eventually consistent
# for brand-new GCP projects; we add a delay as a work-around.
# For more information, see this GitHub issue:
# https://github.com/hashicorp/terraform-provider-google/issues/11020
resource "time_sleep" "wait_for_artifactregistry" {
  create_duration = "20s"
  depends_on = [
    google_project_service.emblem_ops_beta_services
  ]
}

resource "time_sleep" "wait_for_cloud_scheduler" {
  create_duration = "20s"
  depends_on = [
    google_project_service.emblem_ops_services
  ]
}

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

resource "google_artifact_registry_repository" "e2e_runner_docker" {
  format        = "DOCKER"
  location      = var.region
  repository_id = "e2e-runner"
  project       = var.project_id
  provider      = google-beta

  depends_on = [
    time_sleep.wait_for_artifactregistry
  ]
}

###
# Secret Manager
###

# OAuth 2.0 secrets
# These secret resources are REQUIRED, but configuring them is OPTIONAL.
# To avoid leaking secret data, we set their values directly with `gcloud`.
# (Otherwise, Terraform would store secret data unencrypted in .tfstate files.)

# TODO: prod and staging should use different secrets
# See the following GitHub issue:
#   https://github.com/GoogleCloudPlatform/emblem/issues/263
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

###
# Service Accounts (test users for the website)
###
resource "google_service_account" "website_test_user" {
  project      = var.project_id
  account_id   = "website-test-user"
  display_name = "Website Test User"
}

resource "google_service_account" "website_test_approver" {
  project      = var.project_id
  account_id   = "website-test-approver"
  display_name = "Website Test Approver"
}

# This topic is published to once a day via Cloud Scheduler
# Its purpose is to trigger "nightly" builds
resource "google_pubsub_topic" "nightly" {
  name    = "nightly-builds"
  project = var.project_id
}

resource "google_cloud_scheduler_job" "nightly_schedule" {
  project     = var.project_id
  name        = "nightly-builds"
  description = "This job runs all nightly builds"
  region      = var.region
  schedule    = "*/2 * * * *"
  pubsub_target {
    topic_name = google_pubsub_topic.nightly.id
    data       = base64encode("not empty")
  }
  depends_on = [
    google_pubsub_topic.nightly,
    time_sleep.wait_for_artifactregistry
  ]
}
