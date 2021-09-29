data "google_project" "stage_project" {
  project_id = var.google_stage_project_id
}

data "google_project" "prod_project" {
  project_id = var.google_prod_project_id
}

resource "google_project_service" "run_api_stage" {
  provider = google
  project  = data.google_project.stage_project.project_id
  service  = "run.googleapis.com"
}

resource "google_project_service" "run_api_prod" {
  provider = google
  project  = data.google_project.prod_project.project_id
  service  = "run.googleapis.com"
}

resource "google_project_iam_member" "cloudrun_ops_service_agent_stage" {
  provider   = google
  project    = data.google_project.ops_project.project_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${data.google_project.stage_project.number}@serverless-robot-prod.iam.gserviceaccount.com"
  depends_on = [google_project_service.run_api_stage]
}

resource "google_project_iam_member" "cloudrun_ops_service_agent_prod" {
  provider   = google
  project    = data.google_project.ops_project.project_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${data.google_project.prod_project.number}@serverless-robot-prod.iam.gserviceaccount.com"
  depends_on = [google_project_service.run_api_prod]
}

resource "google_artifact_registry_repository_iam_member" "iam_website_ar_stage" {
  project    = data.google_project.ops_project.project_id
  provider   = google-beta
  location   = var.google_region
  repository = google_artifact_registry_repository.website_docker.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${data.google_project.stage_project.number}@serverless-robot-prod.iam.gserviceaccount.com"

  ## Using depends_on because the beta behavior is a little wonky
  depends_on = [
    google_artifact_registry_repository.website_docker,
    google_project_service.cloudrun_api
  ]
}

resource "google_artifact_registry_repository_iam_member" "iam_website_ar_prod" {
  project    = data.google_project.ops_project.project_id
  provider   = google-beta
  location   = var.google_region
  repository = google_artifact_registry_repository.website_docker.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${data.google_project.prod_project.number}@serverless-robot-prod.iam.gserviceaccount.com"

  ## Using depends_on because the beta behavior is a little wonky
  depends_on = [
    google_artifact_registry_repository.website_docker,
    google_project_service.cloudrun_api
  ]
}
