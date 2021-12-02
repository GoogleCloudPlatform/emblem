resource "google_pubsub_topic" "ops_gcr_pubsub" {
  provider = google.ops
  name     = "gcr"
}

resource "google_project_service" "ops_cloudbuild_api" {
  project  = data.google_project.ops_project.project_id
  provider = google.ops
  service  = "cloudbuild.googleapis.com"
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

resource "google_project_service" "ops_secretmanager_api" {
  project  = data.google_project.ops_project.project_id
  provider = google.ops
  service  = "secretmanager.googleapis.com"
}

resource "google_project_service" "ops_artifact_registry_api" {
  project  = data.google_project.ops_project.project_id
  provider = google-beta.ops
  service  = "artifactregistry.googleapis.com"
}

resource "google_artifact_registry_repository" "ops_website_docker" {
  project       = data.google_project.ops_project.project_id
  provider      = google-beta.ops
  location      = var.google_region
  format        = "DOCKER"
  repository_id = "website"

  ## Using depends_on because the beta behavior is a little wonky
  depends_on = [
    google_project_service.ops_artifact_registry_api,
    google_project_iam_member.ops_ar_admin_iam
  ]
}

resource "google_artifact_registry_repository" "ops_api_docker" {
  project       = data.google_project.ops_project.project_id
  provider      = google-beta.ops
  location      = var.google_region
  format        = "DOCKER"
  repository_id = "content-api"

  ## Using depends_on because the beta behavior is a little wonky
  depends_on = [
    google_project_service.ops_artifact_registry_api,
    google_project_iam_member.ops_ar_admin_iam
  ]
}

## Give the Staging Cloud Run service account access to AR repos
resource "google_artifact_registry_repository_iam_member" "stage_iam_api_ar" {
  project    = data.google_project.ops_project.project_id
  provider   = google-beta.ops
  location   = var.google_region
  repository = google_artifact_registry_repository.ops_api_docker.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${data.google_project.stage_project.number}@serverless-robot-prod.iam.gserviceaccount.com"

  ## Using depends_on because the beta behavior is a little wonky
  depends_on = [
    google_artifact_registry_repository.ops_api_docker,
    google_project_service.ops_artifact_registry_api,
    google_project_service.stage_run_api
  ]
}

resource "google_artifact_registry_repository_iam_member" "prod_iam_api_ar" {
  project    = data.google_project.ops_project.project_id
  provider   = google-beta.ops
  location   = var.google_region
  repository = google_artifact_registry_repository.ops_api_docker.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${data.google_project.prod_project.number}@serverless-robot-prod.iam.gserviceaccount.com"

  ## Using depends_on because the beta behavior is a little wonky
  depends_on = [
    google_artifact_registry_repository.ops_api_docker,
    google_project_service.ops_artifact_registry_api,
    google_project_service.prod_run_api
  ]
}

resource "google_artifact_registry_repository_iam_member" "stage_iam_website_ar" {
  project    = data.google_project.ops_project.project_id
  provider   = google-beta.ops
  location   = var.google_region
  repository = google_artifact_registry_repository.ops_website_docker.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${data.google_project.stage_project.number}@serverless-robot-prod.iam.gserviceaccount.com"

  ## Using depends_on because the beta behavior is a little wonky
  depends_on = [
    google_artifact_registry_repository.ops_website_docker,
    google_project_service.ops_artifact_registry_api,
    google_project_service.stage_run_api
  ]
}

resource "google_artifact_registry_repository_iam_member" "prod_iam_website_ar" {
  project    = data.google_project.ops_project.project_id
  provider   = google-beta.ops
  location   = var.google_region
  repository = google_artifact_registry_repository.ops_website_docker.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${data.google_project.prod_project.number}@serverless-robot-prod.iam.gserviceaccount.com"

  ## Using depends_on because the beta behavior is a little wonky
  depends_on = [
    google_artifact_registry_repository.ops_website_docker,
    google_project_service.ops_artifact_registry_api,
    google_project_service.prod_run_api
  ]
}

resource "google_project_iam_member" "ops_ar_admin_iam" {
  project    = data.google_project.ops_project.project_id
  provider   = google.ops
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${data.google_project.ops_project.number}@cloudbuild.gserviceaccount.com"
  depends_on = [google_project_service.ops_cloudbuild_api]
}

resource "google_project_iam_member" "ops_cloudbuild_service_account_user_iam_stage" {
  project    = data.google_project.stage_project.project_id
  provider   = google.stage
  role       = "roles/iam.serviceAccountUser"
  member     = "serviceAccount:${data.google_project.ops_project.number}@cloudbuild.gserviceaccount.com"
  depends_on = [google_project_service.ops_cloudbuild_api]
}

resource "google_project_iam_member" "ops_cloudbuild_run_admin_iam_stage" {
  project    = data.google_project.stage_project.project_id
  provider   = google.stage
  role       = "roles/run.admin"
  member     = "serviceAccount:${data.google_project.ops_project.number}@cloudbuild.gserviceaccount.com"
  depends_on = [google_project_service.ops_cloudbuild_api]
}

resource "google_project_iam_member" "ops_cloudbuild_pubsub_iam_stage" {
  project    = data.google_project.stage_project.project_id
  provider   = google.stage
  role       = "roles/pubsub.publisher"
  member     = "serviceAccount:${data.google_project.ops_project.number}@cloudbuild.gserviceaccount.com"
  depends_on = [google_project_service.ops_cloudbuild_api]
}

resource "google_project_iam_member" "ops_cloudbuild_service_account_user_iam_prod" {
  project    = data.google_project.prod_project.project_id
  provider   = google.prod
  role       = "roles/iam.serviceAccountUser"
  member     = "serviceAccount:${data.google_project.ops_project.number}@cloudbuild.gserviceaccount.com"
  depends_on = [google_project_service.ops_cloudbuild_api]
}

resource "google_project_iam_member" "ops_cloudbuild_run_admin_iam_prod" {
  project    = data.google_project.prod_project.project_id
  provider   = google.prod
  role       = "roles/run.admin"
  member     = "serviceAccount:${data.google_project.ops_project.number}@cloudbuild.gserviceaccount.com"
  depends_on = [google_project_service.ops_cloudbuild_api]
}

resource "google_project_iam_member" "ops_cloudbuild_pubsub_iam_prod" {
  project    = data.google_project.prod_project.project_id
  provider   = google.prod
  role       = "roles/pubsub.publisher"
  member     = "serviceAccount:${data.google_project.ops_project.number}@cloudbuild.gserviceaccount.com"
  depends_on = [google_project_service.ops_cloudbuild_api]
}

# Secret Manager IAM resources
resource "google_secret_manager_secret_iam_member" "ops_secret_access_iam_prod_client_id" {
  project    = data.google_project.ops_project.project_id
  secret_id  = "client-id"
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:cloud-run-manager@${data.google_project.prod_project.project_id}.iam.gserviceaccount.com"
  depends_on = [google_service_account.prod_cloud_run_manager]
}

resource "google_secret_manager_secret_iam_member" "ops_secret_access_iam_prod_client_secret" {
  project    = data.google_project.ops_project.project_id
  secret_id  = "client-secret"
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:cloud-run-manager@${data.google_project.prod_project.project_id}.iam.gserviceaccount.com"
  depends_on = [google_service_account.prod_cloud_run_manager]
}

resource "google_secret_manager_secret_iam_member" "ops_secret_access_iam_stage_client_id" {
  project    = data.google_project.ops_project.project_id
  secret_id  = "client-id"
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:cloud-run-manager@${data.google_project.stage_project.project_id}.iam.gserviceaccount.com"
  depends_on = [google_service_account.stage_cloud_run_manager]
}

resource "google_secret_manager_secret_iam_member" "ops_secret_access_iam_stage_client_secret" {
  project    = data.google_project.ops_project.project_id
  secret_id  = "client-secret"
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:cloud-run-manager@${data.google_project.stage_project.project_id}.iam.gserviceaccount.com"
  depends_on = [google_service_account.stage_cloud_run_manager]
}
