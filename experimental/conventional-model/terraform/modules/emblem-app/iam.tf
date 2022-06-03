##
# Cloud Build & Cloud Run Service Identities
#
# @TODO(#254): Have dedicated service accounts for service x (admin, identity)
##

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

##
# Cloud Build manages Cloud Run services
##

# TODO: narrow scope of IAM permission to only necessary service accounts rather than whole project
resource "google_project_iam_member" "cloudbuild_role_service_account_user" {
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${data.google_project.ops.number}@cloudbuild.gserviceaccount.com"
  project = var.project_id
}

resource "google_project_iam_member" "cloudbuild_role_run_admin" {
  role    = "roles/run.admin"
  member  = "serviceAccount:${data.google_project.ops.number}@cloudbuild.gserviceaccount.com"
  project = var.project_id
}

##
# User Authentication & Testing
##

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

##
# Artifact Registry Access
##

## Cloud Run service agent access to Artifact Registry (Content API).
resource "google_artifact_registry_repository_iam_member" "api_cloudrun_role_ar_reader" {
  provider   = google-beta
  project    = var.ops_project_id
  location   = var.region
  repository = "content-api" // this previously was contrived from ops output
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${data.google_project.app.number}@serverless-robot-prod.iam.gserviceaccount.com"
}

## Cloud Run service agent access to Artifact Registry (Website).
resource "google_artifact_registry_repository_iam_member" "website_cloudrun_role_ar_reader" {
  provider   = google-beta
  project    = var.ops_project_id
  location   = var.region
  repository = "website" // this previously was contrived from ops output
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${data.google_project.app.number}@serverless-robot-prod.iam.gserviceaccount.com"
}
