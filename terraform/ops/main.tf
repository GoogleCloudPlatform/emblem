data "google_project" "main" {
  project_id = var.google_ops_project_id
}

resource "google_project_service" "artifactregistry" {
  service = "artifactregistry.googleapis.com"
  project = data.google_project.main.project_id
  # Artifact Registry is only available in the Beta provider.
  provider = google-beta
}

resource "google_project_service" "cloudbuild" {
  service = "cloudbuild.googleapis.com"
  project = data.google_project.main.project_id
  # Artifact Registry is only available in the Beta provider.
  provider = google-beta
}

resource "google_project_service" "pubsub" {
  service  = "pubsub.googleapis.com"
  project  = data.google_project.main.project_id
  provider = google

  # Cloud Build and many other services require Pub/Sub to be enabled. 
  # If you try to disable Pub/Sub while these services are enabled, it will fail.
  # Therefore, in order to run `terraform destroy`, we need to tell TF that we 
  # want to disable all dependent services.
  disable_dependent_services = true
}

###
# Pub/Sub Topics
###

# Create this topic to emit writes to Artifact Registry as events.
# https://cloud.google.com/artifact-registry/docs/configure-notifications#topic
resource "google_pubsub_topic" "gcr" {
  name     = "gcr"
  project  = data.google_project.main.project_id
  provider = google
}

resource "google_project_iam_member" "pubsub_publisher_iam_member" {
  project  = data.google_project.main.project_id
  provider = google
  role     = "roles/pubsub.publisher"
  member   = "serviceAccount:${data.google_project.main.number}@cloudbuild.gserviceaccount.com"

  depends_on = [
    google_project_service.cloudbuild
  ]
}

###
# Container Hosting
##

resource "time_sleep" "wait_for_artifactregistry" {
  depends_on = [google_project_service.artifactregistry]

  # Some API enablements are eventually consistent.
  # (So, we use a delay to avoid Terraform failures.)
  create_duration = "10s"
}

resource "google_artifact_registry_repository" "website_docker" {
  format        = "DOCKER"
  location      = var.region
  repository_id = "website"
  project       = data.google_project.main.project_id
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
  project       = data.google_project.main.project_id
  provider      = google-beta

  depends_on = [
    # Need to ensure Artifact Registry API is enabled first.
    time_sleep.wait_for_artifactregistry
  ]
}

###
# Secret Manager
###

resource "google_project_service" "secretmanager" {
  service  = "secretmanager.googleapis.com"
  project  = data.google_project.main.project_id
  provider = google
}

# OAuth 2.0 secrets
# These secret resources are REQUIRED, but configuring them is OPTIONAL.
# To avoid leaking secret data, we set their values directly with `gcloud`.
# (Otherwise, Terraform would store secret data unencrypted in .tfstate files.)

# TODO: prod and staging should use different secrets
# See the following GitHub issue:
#   https://github.com/GoogleCloudPlatform/emblem/issues/263
resource "google_secret_manager_secret" "oauth_client_id" {
  project   = data.google_project.main.project_id
  secret_id = "client_id_secret"
  replication {
    automatic = "true"
  }

  # Adding depends_on prevents race conditions in API enablement
  # This is a workaround for:
  #   https://github.com/hashicorp/terraform-provider-google/issues/10682
  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret" "oauth_client_secret" {
  project   = data.google_project.main.project_id
  secret_id = "client_secret_secret"
  replication {
    automatic = "true"
  }

  # Adding depends_on prevents race conditions in API enablement
  # This is a workaround for:
  #   https://github.com/hashicorp/terraform-provider-google/issues/10682
  depends_on = [google_project_service.secretmanager]
}

