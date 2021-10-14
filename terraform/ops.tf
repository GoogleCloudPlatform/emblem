provider "google" {
  alias   = "ops"
  project = data.google_project.ops_project.project_id
  region  = var.google_region
}

resource "google_pubsub_topic" "ops_gcr_pubsub" {
  provider = google.ops
  name     = "gcr"

}

resource "google_project_service" "ops_cloudbuild_api" {
  provider = google.ops
  service  = "cloudbuild.googleapis.com"
}

resource "google_project_service" "ops_pubsub_api" {
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
  provider = google-beta
  service  = "artifactregistry.googleapis.com"
}

resource "google_artifact_registry_repository" "ops_website_docker" {
  provider      = google-beta
  location      = var.google_region
  format        = "DOCKER"
  repository_id = "website"
  depends_on    = [google_project_service.ops_artifact_registry_api]
  ## Using depends_on because the beta behavior is a little wonky
}

resource "google_artifact_registry_repository" "ops_api_docker" {
  provider      = google-beta
  location      = var.google_region
  format        = "DOCKER"
  repository_id = "content-api"
  depends_on    = [google_project_service.ops_artifact_registry_api]
  ## Using depends_on because the beta behavior is a little wonky
}

## Give the Staging Cloud Run service account access to AR repos
resource "google_artifact_registry_repository_iam_member" "stage_iam_api_ar" {
  provider   = google-beta
  location   = var.google_region
  repository = google_artifact_registry_repository.ops_api_docker.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${data.google_project.stage_project.number}@serverless-robot-prod.iam.gserviceaccount.com"
  depends_on = [google_artifact_registry_repository.ops_api_docker]
  ## Using depends_on because the beta behavior is a little wonky
}

resource "google_artifact_registry_repository_iam_member" "prod_iam_api_ar" {
  provider   = google-beta
  location   = var.google_region
  repository = google_artifact_registry_repository.ops_api_docker.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${data.google_project.prod_project.number}@serverless-robot-prod.iam.gserviceaccount.com"
  depends_on = [google_artifact_registry_repository.ops_api_docker]
  ## Using depends_on because the beta behavior is a little wonky
}

resource "google_artifact_registry_repository_iam_member" "stage_iam_website_ar" {
  provider   = google-beta
  location   = var.google_region
  repository = google_artifact_registry_repository.ops_website_docker.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${data.google_project.stage_project.number}@serverless-robot-prod.iam.gserviceaccount.com"
  depends_on = [google_artifact_registry_repository.ops_website_docker]
  ## Using depends_on because the beta behavior is a little wonky
}

resource "google_artifact_registry_repository_iam_member" "prod_iam_website_ar" {
  provider   = google-beta
  location   = var.google_region
  repository = google_artifact_registry_repository.ops_website_docker.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${data.google_project.prod_project.number}@serverless-robot-prod.iam.gserviceaccount.com"
  depends_on = [google_artifact_registry_repository.ops_website_docker]
  ## Using depends_on because the beta behavior is a little wonky
}

resource "google_project_iam_member" "ops_ar_admin_iam" {
  provider   = google.ops
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${data.google_project.ops_project.number}@cloudbuild.gserviceaccount.com"
  depends_on = [google_project_service.ops_cloudbuild_api]
}

resource "google_project_iam_member" "ops_cloudbuild_service_account_user_iam_stage" {
  provider   = google.stage
  role       = "roles/iam.serviceAccountUser"
  member     = "serviceAccount:${data.google_project.ops_project.number}@cloudbuild.gserviceaccount.com"
  depends_on = [google_project_service.ops_cloudbuild_api]
}

resource "google_project_iam_member" "ops_cloudbuild_run_admin_iam_stage" {
  provider   = google.stage
  role       = "roles/run.admin"
  member     = "serviceAccount:${data.google_project.ops_project.number}@cloudbuild.gserviceaccount.com"
  depends_on = [google_project_service.ops_cloudbuild_api]
}

resource "google_project_iam_member" "ops_cloudbuild_pubsub_iam_stage" {
  provider   = google.stage
  role       = "roles/pubsub.publisher"
  member     = "serviceAccount:${data.google_project.ops_project.number}@cloudbuild.gserviceaccount.com"
  depends_on = [google_project_service.ops_cloudbuild_api]
}

resource "google_project_iam_member" "ops_cloudbuild_service_account_user_iam_prod" {
  provider   = google.prod
  role       = "roles/iam.serviceAccountUser"
  member     = "serviceAccount:${data.google_project.ops_project.number}@cloudbuild.gserviceaccount.com"
  depends_on = [google_project_service.ops_cloudbuild_api]
}

resource "google_project_iam_member" "ops_cloudbuild_run_admin_iam_prod" {
  provider   = google.prod
  role       = "roles/run.admin"
  member     = "serviceAccount:${data.google_project.ops_project.number}@cloudbuild.gserviceaccount.com"
  depends_on = [google_project_service.ops_cloudbuild_api]
}

resource "google_project_iam_member" "ops_cloudbuild_pubsub_iam_prod" {
  provider   = google.prod
  role       = "roles/pubsub.publisher"
  member     = "serviceAccount:${data.google_project.ops_project.number}@cloudbuild.gserviceaccount.com"
  depends_on = [google_project_service.ops_cloudbuild_api]
}
