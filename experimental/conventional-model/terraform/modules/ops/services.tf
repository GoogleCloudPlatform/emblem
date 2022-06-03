locals {
  services = var.enable_apis ? [
    "cloudbuild.googleapis.com",
    "pubsub.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudscheduler.googleapis.com"
  ] : []
  # Artifact registry service only available in Google beta provider
  beta_services = var.enable_apis ? [
    "artifactregistry.googleapis.com"
  ] : []
}

resource "google_project_service" "emblem_ops_services" {
  for_each                   = toset(local.services)
  project                    = var.project_id
  service                    = each.value
  disable_dependent_services = true
  disable_on_destroy         = false
}

resource "google_project_service" "emblem_ops_beta_services" {
  for_each                   = toset(local.beta_services)
  provider                   = google-beta
  project                    = var.project_id
  service                    = each.value
  disable_dependent_services = true
  disable_on_destroy         = false
}
