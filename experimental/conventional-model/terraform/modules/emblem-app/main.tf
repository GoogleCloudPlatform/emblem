# The following will check if a app engine default service account exists
# If it already does, Terraform will not create an Appengine App
# This is a work around for Terraform being unable to truely destroy
# an app engine application
# Issue: https://github.com/hashicorp/terraform-provider-google/issues/10351#issuecomment-1116555590
data "google_app_engine_default_service_account" "default" {
  project = var.project_id
}

resource "google_app_engine_application" "main" {
  count         = data.google_app_engine_default_service_account.default.unique_id == null ? 1 : 0
  project       = var.project_id
  location_id   = replace(trimspace(var.region), "/\\d+$/", "")
  database_type = "CLOUD_FIRESTORE"
  depends_on = [
    google_project_service.emblem_app_services
  ]
}

data "google_project" "app" {
  project_id = var.project_id
}

data "google_project" "ops" {
  project_id = var.ops_project_id
}

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

## Cloud Run service agent access to Artifact Registry (Content API).
# TODO: Migrate resource over to Ops module
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

###
# Pipeline Orchestration
###

resource "google_pubsub_topic" "canary" {
  name    = "canary-${var.project_id}"
  project = var.project_id
}

resource "google_pubsub_topic" "deploy" {
  name    = "deploy-${var.project_id}"
  project = var.project_id
}