# Dynamic data sources

data "google_cloud_run_service" "content_api" {
  project  = var.project_id
  name     = "content-api"
  location = var.region
}
