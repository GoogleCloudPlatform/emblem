resource "google_project" "ops_project" {
  name       = "Emblem Ops"
  project_id = "emblem-ops-${var.suffix}"
  billing_account = var.billing_account
}

provider "google" {
  alias = "ops"
  project = google_project.ops_project.project_id
  region  = var.google_region
}

resource "google_pubsub_topic" "ops_gcr_pubsub" {
  provider = google.ops
  name    = "gcr"
}

resource "google_pubsub_topic" "ops_cloudbuilds_pubsub" {
  provider = google.ops
  name    = "cloud-builds"
}

resource "google_project_service" "ops_cloudbuild_api" {
  provider = google.ops
  service = "cloudbuild.googleapis.com"
}

resource "google_project_service" "ops_pubsub_api" {
  provider = google.ops
  service = "pubsub.googleapis.com"
  disable_dependent_services = true
}

provider "google-beta" {
  project = google_project.ops_project.project_id
  region  = var.google_region
}

resource "google_project_service" "ops_artifact_registry_api" {
  provider = google-beta
  service = "artifactregistry.googleapis.com"
}

resource "google_artifact_registry_repository" "ops_website_docker" {
  provider = google-beta
  location = var.google_region

  format = "DOCKER"
  repository_id = "website"
  ## Using depends_on because the beta behavior is a little wonky
  depends_on = [google_project_service.ops_artifact_registry_api]
}

resource "google_artifact_registry_repository" "ops_api_docker" {
  provider = google-beta
  location = var.google_region

  format = "DOCKER"
  repository_id = "content-api"
  ## Using depends_on because the beta behavior is a little wonky
  depends_on = [google_project_service.ops_artifact_registry_api]
}

## Give the Staging Cloud Run service account access to AR repos
resource "google_artifact_registry_repository_iam_member" "stage_iam_api_ar" {
  provider = google-beta

  location = var.google_region
  repository = google_artifact_registry_repository.ops_api_docker.name
  role   = "roles/artifactregistry.reader"
  member = "serviceAccount:service-${google_project.stage_project.number}@serverless-robot-prod.iam.gserviceaccount.com"
  ## Using depends_on because the beta behavior is a little wonky
  depends_on = [google_artifact_registry_repository.ops_api_docker]
}

resource "google_artifact_registry_repository_iam_member" "stage_iam_website_ar" {
  provider = google-beta

  location = var.google_region
  repository = google_artifact_registry_repository.ops_website_docker.name
  role   = "roles/artifactregistry.reader"
  member = "serviceAccount:service-${google_project.stage_project.number}@serverless-robot-prod.iam.gserviceaccount.com"
  ## Using depends_on because the beta behavior is a little wonky
  depends_on = [google_artifact_registry_repository.ops_website_docker]
}

data "google_iam_policy" "ops_ar_admin_iam" {
  provider = google.ops
  binding {
    role = "roles/artifactregistry.writer"

    members = [
      "serviceAccount:${google_project.ops_project.number}@cloudbuild.gserviceaccount.com",
    ]
  }
}
