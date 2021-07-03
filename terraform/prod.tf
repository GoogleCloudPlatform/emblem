provider "google" {
  alias = "prod"
  project = google_project.prod_project.project_id
  region  = var.google_region
}

resource "google_project" "prod_project" {
  name       = "Emblem Prod"
  project_id = "emblem-prod-${var.suffix}"
  billing_account = var.billing_account
}

resource "google_service_account" "prod_cloud_run_manager" {
  account_id   = "cloud-run-manager"
  description  = "Account for deploying new revisions and controlling traffic to Cloud Run"
  display_name = "cloud-run-manager"
  provider = google.prod
}

resource "google_pubsub_topic" "prod_canary_pubsub" {
  name    = "canary"
  provider = google.prod
}

resource "google_pubsub_topic" "prod_cloudbuilds_pubsub" {
  name    = "cloud-builds"
  provider = google.prod
}

resource "google_project_service" "prod_cloudbuild_api" {
  provider = google.prod
  service = "cloudbuild.googleapis.com"
}

resource "google_project_service" "prod_run_api" {
  provider = google.prod
  service = "run.googleapis.com"
}

resource "google_project_service" "prod_pubsub_api" {
  provider = google.prod
  service = "pubsub.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_iam_member" "prod_cloudbuild_service_account_user_iam" {
  provider = google.prod
  role   = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${google_project.prod_project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "prod_cloudbuild_run_admin_iam" {
  provider = google.prod
  role   = "roles/run.admin"
  member = "serviceAccount:${google_project.prod_project.number}@cloudbuild.gserviceaccount.com"
}

