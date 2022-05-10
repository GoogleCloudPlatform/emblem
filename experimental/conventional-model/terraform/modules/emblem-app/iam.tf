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

resource "google_secret_manager_secret_iam_member" "secret_access_iam_client_id" {
  project   = var.ops_project_id
  secret_id = "client_id_secret" // this previously was contrived from ops remote state
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.website_manager.email}"
}

resource "google_secret_manager_secret_iam_member" "secret_access_iam_client_secret" {
  project   = var.ops_project_id
  secret_id = "client_secret_secret" // this previously was contrived from ops remote state
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.website_manager.email}"
}