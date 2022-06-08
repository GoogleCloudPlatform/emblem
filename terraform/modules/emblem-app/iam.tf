resource "google_service_account" "cloud_run_manager" {
  project      = var.project_id
  account_id   = "cloud-run-manager"
  description  = "Deploys new revisions and controls traffic to Cloud Run."
  display_name = "cloud-run-manager"
}

resource "google_service_account" "website_manager" {
  project      = var.project_id
  account_id   = "website-manager"
  description  = "Manages website deployments on Cloud Run."
  display_name = "website-manager"
}

resource "google_service_account" "api_manager" {
  project      = var.project_id
  account_id   = "api-manager"
  description  = "Manages API deployments on Cloud Run."
  display_name = "api-manager"
}

# Note: any roles used here must be added to this file to prevent CI failures
# installation-testing/terraform/modules/emblem-app/delivery_testing.tf

resource "google_project_iam_member" "project" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.api_manager.email}"
}

resource "google_secret_manager_secret_iam_member" "secret_access_iam_client_id" {
  project   = var.ops_project_id
  secret_id = "client_id_secret" // this previously was contrived from ops remote state
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.website_manager.email}"
}

resource "google_secret_manager_secret_iam_member" "secret_access_iam_client_secret" {
  project   = var.ops_project_id
  secret_id = "client_secret_secret" // this previously was contrived from ops remote state
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.website_manager.email}"
}

## Cloud Run service agent access to Artifact Registry (Content API).
resource "google_artifact_registry_repository_iam_member" "api_cloudrun_role_ar_reader" {
  provider   = google-beta
  project    = var.ops_project_id
  location   = var.region
  repository = "content-api" // this previously was contrived from ops output
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${data.google_project.app.number}@serverless-robot-prod.iam.gserviceaccount.com"
  depends_on = [
    google_project_service.emblem_app_services
  ]
}


## Cloud Run service agent access to Artifact Registry (Website).
resource "google_artifact_registry_repository_iam_member" "website_cloudrun_role_ar_reader" {
  provider   = google-beta
  project    = var.ops_project_id
  location   = var.region
  repository = "website" // this previously was contrived from ops output
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${data.google_project.app.number}@serverless-robot-prod.iam.gserviceaccount.com"
  depends_on = [
    google_project_service.emblem_app_services
  ]
}
