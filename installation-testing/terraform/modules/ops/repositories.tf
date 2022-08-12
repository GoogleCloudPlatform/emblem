resource "google_artifact_registry_repository" "installation_testing_docker" {
  format        = "DOCKER"
  location      = var.region
  repository_id = "installation-testing"
  project       = var.project_id
  provider      = google-beta
}
