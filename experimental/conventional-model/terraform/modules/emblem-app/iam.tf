resource "google_service_account" "cloud_run_manager" {
  project      = var.project_id
  account_id   = "cloud-run-manager"
  description  = "Deploys new revisions and controls traffic to Cloud Run."
  display_name = "cloud-run-manager"
}

resource "google_service_account" "website_manager" {
  project      = var.project_id
  account_id   = "website-manager"
  description  = "Manages website deployments on Cloud Run."
  display_name = "website-manager"
}

resource "google_service_account" "api_manager" {
  project      = var.project_id
  account_id   = "api-manager"
  description  = "Manages API deployments on Cloud Run."
  display_name = "api-manager"
}
