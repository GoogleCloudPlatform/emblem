data "google_project" "main" {
  project_id = var.google_ops_project_id
}

resource "google_project_service" "artifactregistry" {
  service  = "artifactregistry.googleapis.com"
  project  = data.google_project.main.project_id
  # Artifact Registry is only available in the Beta provider.
  provider = google-beta
}

resource "google_project_service" "cloudbuild" {
  service  = "cloudbuild.googleapis.com"
  project  = data.google_project.main.project_id
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
# Access Control / IAM 
###

# Add Artifact Registry Writer role to the Cloud Build default service account.
resource "google_project_iam_member" "cloudbuild_role_ar_writer" {
  project    = data.google_project.main.project_id
  provider   = google-beta
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${data.google_project.main.number}@cloudbuild.gserviceaccount.com"
  depends_on = [google_project_service.cloudbuild]
}

###
# Pub/Sub Topics
###

resource "google_pubsub_topic" "canary" {
  name     = "canary"
  project  = data.google_project.main.project_id
  provider = google
}

# Create this topic to emit writes to Artifact Registry as events.
# https://cloud.google.com/artifact-registry/docs/configure-notifications#topic
resource "google_pubsub_topic" "gcr" {
  name     = "gcr"
  project  = data.google_project.main.project_id
  provider = google
}

###
# Container Hosting
##

resource "google_artifact_registry_repository" "website_docker" {
  format        = "DOCKER"
  location      = var.region
  repository_id = "website"
  project       = data.google_project.main.project_id
  provider      = google-beta

  depends_on = [
    # Need to enable Artifact Registry service before repository creation.
    google_project_service.artifactregistry,
    # TODO: Verify Cloud Build write access is a required dependency.
    google_project_iam_member.cloudbuild_role_ar_writer
  ]
}

resource "google_artifact_registry_repository" "api_docker" {
  format        = "DOCKER"
  location      = var.region
  repository_id = "content-api"
  project       = data.google_project.main.project_id
  provider      = google-beta

  depends_on = [
    # Need to enable Artifact Registry service before repository creation.
    google_project_service.artifactregistry,
    # TODO: Verify Cloud Build write access is a required dependency.
    google_project_iam_member.cloudbuild_role_ar_writer
  ]
}
