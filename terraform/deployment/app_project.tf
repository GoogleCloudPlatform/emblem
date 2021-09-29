provider "google" {
  alias   = "google_provider"
  project = data.google_project.app_project.project_id
  region  = var.google_region
}

data "google_project" "app_project" {
  project_id = var.google_app_project_id
}

data "google_project" "ops_project" {
  project_id = var.google_ops_project_id
}

resource "google_service_account" "cloud_run_manager" {
  project      = data.google_project.app_project.project_id
  account_id   = "cloud-run-manager"
  description  = "Account for deploying new revisions and controlling traffic to Cloud Run"
  display_name = "cloud-run-manager"
  provider     = google
}

resource "google_service_account" "cloud_run_robot" {
  project      = data.google_project.app_project.project_id
  account_id   = "serverless-robot-prod"
  description  = "Auto-generated account created by Terraform, and used by Cloud Run"
  display_name = "serverless-robot-prod"
  provider     = google
}

resource "google_pubsub_topic" "canary" {
  project    = data.google_project.app_project.project_id
  name       = "canary"
  provider   = google
  depends_on = [google_project_service.pubsub_api]
}

resource "google_pubsub_topic" "cloudbuilds_pubsub" {
  project    = data.google_project.app_project.project_id
  name       = "cloud-builds"
  provider   = google
  depends_on = [google_project_service.pubsub_api]
}

resource "google_project_service" "cloudbuild_api" {
  provider = google
  project  = data.google_project.app_project.project_id
  service  = "cloudbuild.googleapis.com"
}

resource "google_project_service" "firestore_api" {
  provider = google
  project  = data.google_project.app_project.project_id
  service  = "firestore.googleapis.com"
}

resource "google_project_service" "pubsub_api" {
  provider                   = google
  project                    = data.google_project.app_project.project_id
  service                    = "pubsub.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_iam_member" "cloudbuild_service_account_user" {
  provider   = google
  project    = data.google_project.app_project.project_id
  role       = "roles/iam.serviceAccountUser"
  member     = "serviceAccount:${data.google_project.ops_project.number}@cloudbuild.gserviceaccount.com"
  depends_on = [google_project_service.cloudbuild_api]
}

resource "google_project_iam_member" "cloudbuild_run_admin" {
  provider   = google
  project    = data.google_project.app_project.project_id
  role       = "roles/run.admin"
  member     = "serviceAccount:${data.google_project.ops_project.number}@cloudbuild.gserviceaccount.com"
  depends_on = [google_project_service.cloudbuild_api]
}

resource "google_project_iam_member" "ar_reader" {
  provider = google
  project  = data.google_project.ops_project.project_id
  role     = "roles/artifactregistry.reader"
  member   = "serviceAccount:${data.google_project.app_project.number}@cloudbuild.gserviceaccount.com"
}

# Set up Firestore in Native Mode
# https://firebase.google.com/docs/firestore/solutions/automate-database-create#create_a_database_with_terraform
resource "google_project_service" "appengine_api" {
  provider = google
  project  = data.google_project.app_project.project_id
  service  = "appengine.googleapis.com"
}
