provider "google" {
  alias = "stage"
  project = google_project.stage_project.project_id
  region  = var.google_region
}

resource "google_project" "stage_project" {
  name       = "Emblem Stage"
  project_id = "emblem-stage-${var.suffix}"
  billing_account = var.billing_account
}

resource "google_service_account" "stage_cloud_run_manager" {
  account_id   = "cloud-run-manager"
  description  = "Account for deploying new revisions and controlling traffic to Cloud Run"
  display_name = "cloud-run-manager"
  provider = google.stage
}

resource "google_pubsub_topic" "stage_canary_pubsub" {
  name    = "canary"
  provider = google.stage
}

resource "google_pubsub_topic" "stage_cloudbuilds_pubsub" {
  name    = "cloud-builds"
  provider = google.stage
}

resource "google_project_service" "stage_cloudbuild_api" {
  provider = google.stage
  service = "cloudbuild.googleapis.com"
}

resource "google_project_service" "stage_run_api" {
  provider = google.stage
  service = "run.googleapis.com"
}

resource "google_project_service" "stage_pubsub_api" {
  provider = google.stage
  service = "pubsub.googleapis.com"
  disable_dependent_services = true
}

data "google_iam_policy" "ops_cloudbuild_service_account_user_iam" {
  provider = google.stage
  binding {
    role = "roles/iam.serviceAccountUser"

    members = [
      "serviceAccount:${google_project.ops_project.number}@cloudbuild.gserviceaccount.com",
    ]
  }
}

data "google_iam_policy" "ops_cloudbuild_run_admin_iam" {
  provider = google.stage
  binding {
    role = "roles/run.admin"

    members = [
      "serviceAccount:${google_project.ops_project.number}@cloudbuild.gserviceaccount.com",
    ]
  }
}
