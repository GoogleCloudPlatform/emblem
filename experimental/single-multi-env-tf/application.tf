data "google_project" "app" {
  for_each   = var.environments
  project_id = each.value
}

module "application" {
  for_each          = var.environments
  source            = "./application"
  environment       = each.key
  google_project_id = each.value
}

###
# IAM & Access Control
###

# Add Service Account User role to Cloud Build service account.
resource "google_project_iam_member" "cloudbuild_role_service_account_user" {
  for_each = var.environments
  role     = "roles/iam.serviceAccountUser"
  member   = "serviceAccount:${data.google_project.main.number}@cloudbuild.gserviceaccount.com"
  project  = each.value
  provider = google
  # Ensure the Cloud Build service account is available.
  depends_on = [google_project_service.cloudbuild]
}

# Add Cloud Run Admin role to Cloud Build service account.
resource "google_project_iam_member" "cloudbuild_role_run_admin" {
  for_each = var.environments
  role     = "roles/run.admin"
  member   = "serviceAccount:${data.google_project.main.number}@cloudbuild.gserviceaccount.com"
  project  = each.value
  provider = google

  # Ensure the Cloud Build service account is available.
  depends_on = [google_project_service.cloudbuild]
}

## Cloud Run service agent access to Artifact Registry (Content API).
resource "google_artifact_registry_repository_iam_member" "api_cloudrun_role_ar_reader" {
  for_each   = var.environments
  location   = var.region
  repository = google_artifact_registry_repository.api_docker.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${data.google_project.app[each.key].number}@serverless-robot-prod.iam.gserviceaccount.com"
  project    = data.google_project.main.project_id
  provider   = google-beta

  depends_on = [
    # Ensure environment setup, specifically Cloud Run service agent.
    module.application
  ]
}

## Cloud Run service agent access to Artifact Registry (Website).
resource "google_artifact_registry_repository_iam_member" "website_cloudrun_role_ar_reader" {
  for_each   = var.environments
  location   = var.region
  repository = google_artifact_registry_repository.website_docker.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${data.google_project.app[each.key].number}@serverless-robot-prod.iam.gserviceaccount.com"
  project    = data.google_project.main.project_id
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
  for_each = var.environments
  name     = "canary-${each.key}"
  project  = data.google_project.main.project_id
  provider = google
}
