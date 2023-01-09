locals {
  services = var.enable_apis ? [
    "cloudbuild.googleapis.com",
    "pubsub.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudscheduler.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com"
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

resource "time_sleep" "wait_for_cloud_build_service" {
  create_duration = "20s"
  depends_on = [
    google_project_service.emblem_ops_services
  ]
}

resource "time_sleep" "wait_for_iam_service" {
  create_duration = "20s"
  depends_on = [
    google_project_service.emblem_ops_services
  ]
}

# Artifact Registry API enablement is eventually consistent
# for brand-new GCP projects; we add a delay as a work-around.
# For more information, see this GitHub issue:
# https://github.com/hashicorp/terraform-provider-google/issues/11020
resource "time_sleep" "wait_for_artifactregistry" {
  create_duration = "40s"
  depends_on = [
    google_project_service.emblem_ops_beta_services
  ]
}

resource "time_sleep" "wait_for_cloud_scheduler" {
  create_duration = "40s"
  depends_on = [
    google_project_service.emblem_ops_services
  ]
}
