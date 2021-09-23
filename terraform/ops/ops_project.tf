data "google_project" "ops_project" {
  project_id = var.google_ops_project_id
}

data "google_project" "app_project" {
  project_id = var.google_app_project_id
}

provider "google" {
  alias   = "ops"
  project = data.google_project.ops_project.project_id
  region  = var.google_region
}

resource "google_service_account" "cloud_run_manager" {
  project      = data.google_project.ops_project.project_id
  account_id   = "cloud-run-manager"
  description  = "Account for deploying new revisions and controlling traffic to Cloud Run"
  display_name = "cloud-run-manager"
  provider     = google
}

resource "google_pubsub_topic" "ops_gcr_pubsub" {
  project = data.google_project.ops_project.project_id
  provider   = google.ops
  name       = "gcr"
  depends_on = [google_project_service.ops_pubsub_api]
}

resource "google_pubsub_topic" "ops_cloudbuilds_pubsub" {
  project = data.google_project.ops_project.project_id
  provider   = google.ops
  name       = "cloud-builds"
  depends_on = [google_project_service.ops_pubsub_api]
}

resource "google_project_service" "ops_cloudbuild_api" {
  project  = data.google_project.ops_project.project_id
  provider = google.ops
  service  = "cloudbuild.googleapis.com"
}

resource "google_project_service" "ops_cloudrun_api" {
  project  = data.google_project.ops_project.project_id
  provider = google.ops
  service  = "run.googleapis.com"
}

resource "google_project_service" "ops_pubsub_api" {
  project  = data.google_project.ops_project.project_id
  provider = google.ops
  service  = "pubsub.googleapis.com"

  # Cloud Build and many other services require Pub/Sub to be enabled. 
  # If you try to disable Pub/Sub while these services are enabled, it will fail.
  # Therefore, in order to run `terraform destroy`, we need to tell TF that we 
  # want to disable all dependent services.

  disable_dependent_services = true
}

provider "google-beta" {
  project = data.google_project.ops_project.project_id
  region  = var.google_region
}

resource "google_project_service" "ops_artifact_registry_api" {
  project  = data.google_project.ops_project.project_id
  provider = google
  service  = "artifactregistry.googleapis.com"

  # Beta behavior is flaky and this may need
  # manual enabling, so don't auto-disable it
  disable_on_destroy = "false"
}

resource "google_artifact_registry_repository" "ops_website_docker" {
  project       = data.google_project.ops_project.project_id
  provider      = google-beta
  location      = var.google_region
  format        = "DOCKER"
  repository_id = "website"
  depends_on    = [google_project_service.ops_artifact_registry_api]
  ## Using depends_on because the beta behavior is a little wonky
}

resource "google_artifact_registry_repository" "ops_api_docker" {
  project       = data.google_project.ops_project.project_id
  provider      = google-beta
  location      = var.google_region
  format        = "DOCKER"
  repository_id = "content-api"
  depends_on    = [google_project_service.ops_artifact_registry_api]
  ## Using depends_on because the beta behavior is a little wonky
}

resource "google_artifact_registry_repository_iam_member" "iam_website_ar" {
  project = data.google_project.ops_project.project_id
  provider   = google-beta
  location   = var.google_region
  repository = google_artifact_registry_repository.ops_website_docker.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${data.google_project.app_project.number}@serverless-robot-prod.iam.gserviceaccount.com"

  ## Using depends_on because the beta behavior is a little wonky
  depends_on = [
    google_artifact_registry_repository.ops_website_docker,
    google_project_service.ops_cloudrun_api
  ]
}

resource "google_project_iam_member" "ops_ar_admin_iam" {
  provider   = google.ops
  project    = data.google_project.ops_project.project_id
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${data.google_project.ops_project.number}@cloudbuild.gserviceaccount.com"
  depends_on = [google_project_service.ops_cloudbuild_api]
}

resource "google_project_iam_member" "ops_cloudbuild_service_account_user_iam" {
  provider   = google
  project    = data.google_project.ops_project.project_id
  role       = "roles/iam.serviceAccountUser"
  member     = "serviceAccount:${data.google_project.ops_project.number}@cloudbuild.gserviceaccount.com"
  depends_on = [google_project_service.ops_cloudbuild_api]
}

resource "google_project_iam_member" "ops_cloudbuild_run_admin_iam" {
  provider   = google
  project    = data.google_project.ops_project.project_id
  role       = "roles/run.admin"
  member     = "serviceAccount:${data.google_project.ops_project.number}@cloudbuild.gserviceaccount.com"
  depends_on = [google_project_service.ops_cloudbuild_api]
}

resource "google_project_iam_member" "ops_cloudbuild_pubsub_iam" {
  provider   = google
  project    = data.google_project.ops_project.project_id
  role       = "roles/pubsub.publisher"
  member     = "serviceAccount:${data.google_project.ops_project.number}@cloudbuild.gserviceaccount.com"
  depends_on = [google_project_service.ops_cloudbuild_api]
}

# Cloud Build triggers

