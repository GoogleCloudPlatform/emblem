data "google_project" "application_project" {
  project_id = var.google_project_id
}

resource "google_project_service" "run_api" {
  project  = var.google_project_id
  service  = "run.googleapis.com"
}