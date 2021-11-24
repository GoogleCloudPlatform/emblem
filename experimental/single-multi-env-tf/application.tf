module "application" {
  for_each = var.environments
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
  role       = "roles/iam.serviceAccountUser"
  member     = "serviceAccount:${data.google_project.main.number}@cloudbuild.gserviceaccount.com"
  project    = each.value
  provider   = google
  # Ensure the Cloud Build service account is available.
  depends_on = [google_project_service.cloudbuild]
}

# Add Cloud Run Admin role to Cloud Build service account.
resource "google_project_iam_member" "cloudbuild_role_run_admin" {
  for_each = var.environments
  role       = "roles/run.admin"
  member     = "serviceAccount:${data.google_project.main.number}@cloudbuild.gserviceaccount.com"
  project    = each.value
  provider   = google

  # Ensure the Cloud Build service account is available.
  depends_on = [google_project_service.cloudbuild]
}
