# Dynamic data sources

data "google_cloud_run_service" "content_api" {
  name = "content-api"
  location = var.region
}
