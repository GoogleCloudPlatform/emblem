terraform {
  backend "local" {}
}

data "google_project" "main" {
  project_id = var.google_project_id
}

data "google_project" "ops" {
  project_id = var.google_ops_project_id
}

# Lookup data from the ops root module.
# Requires the local machine runs the ops module first.
# TODO: Use GCS backend for state so we can reference without rebuild.
# Current use for this is repo references in the google_artifact_registry_repository_iam_member blocks
# However, the values we need are "content-api" and "website", so it may be worth hard-coding instead of
# creating the dynamic dependency.
data "terraform_remote_state" "ops" {
  backend = "local"
  config = {
    path = "../ops/terraform.tfstate"
  }
}

module "application" {
  source            = "./application"
  google_project_id = var.google_project_id
}

###
# IAM & Access Control
###

# Add Service Account User role to Cloud Build service account.
resource "google_project_iam_member" "cloudbuild_role_service_account_user" {
  role     = "roles/iam.serviceAccountUser"
  member   = "serviceAccount:${data.google_project.ops.number}@cloudbuild.gserviceaccount.com"
  project  = data.google_project.main.id
  provider = google
  # Ensure the Cloud Build service account is available.
  # This root module depends on the ops root module having already run.
  # If the root modules are combined, uncomment this dependency.
  # depends_on = [google_project_service.cloudbuild]
}

# Add Cloud Run Admin role to Cloud Build service account.
resource "google_project_iam_member" "cloudbuild_role_run_admin" {
  role     = "roles/run.admin"
  member   = "serviceAccount:${data.google_project.ops.number}@cloudbuild.gserviceaccount.com"
  project  = data.google_project.main.id
  provider = google

  # Ensure the Cloud Build service account is available.
  # This root module depends on the ops root module having already run.
  # If the root modules are combined, uncomment this dependency.
  # depends_on = [google_project_service.cloudbuild]
}

## Cloud Run service agent access to Artifact Registry (Content API).
resource "google_artifact_registry_repository_iam_member" "api_cloudrun_role_ar_reader" {
  location   = var.region
  repository = data.terraform_remote_state.ops.outputs.artifact_registry.api
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${data.google_project.main.number}@serverless-robot-prod.iam.gserviceaccount.com"
  project    = data.google_project.ops.project_id
  provider   = google-beta

  depends_on = [
    # Ensure environment setup, specifically Cloud Run service agent.
    module.application
  ]
}

## Cloud Run service agent access to Artifact Registry (Website).
resource "google_artifact_registry_repository_iam_member" "website_cloudrun_role_ar_reader" {
  location   = var.region
  repository = data.terraform_remote_state.ops.outputs.artifact_registry.website
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${data.google_project.main.number}@serverless-robot-prod.iam.gserviceaccount.com"
  project    = data.google_project.ops.project_id
  provider   = google-beta

  depends_on = [
    # Ensure environment setup, specifically Cloud Run service agent.
    module.application
  ]
}

###
# Pipeline Orchestration
###

resource "google_pubsub_topic" "canary" {
  name     = "canary-${data.google_project.main.project_id}"
  project  = data.google_project.ops.project_id
  provider = google
}
