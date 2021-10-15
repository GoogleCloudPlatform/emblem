resource "google_service_account" "stage_cloud_run_manager" {
  account_id   = "cloud-run-manager"
  description  = "Account for deploying new revisions and controlling traffic to Cloud Run"
  display_name = "cloud-run-manager"
  provider     = google.stage
}

resource "google_pubsub_topic" "stage_canary_pubsub" {
  name     = "canary"
  provider = google.stage
}

resource "google_project_service" "stage_cloudbuild_api" {
  provider = google.stage
  service  = "cloudbuild.googleapis.com"
}

resource "google_project_service" "stage_firestore_api" {
  provider = google.stage
  service  = "firestore.googleapis.com"
}

resource "google_project_service" "stage_run_api" {
  provider = google.stage
  service  = "run.googleapis.com"
}

resource "google_project_service" "stage_pubsub_api" {
  provider                   = google.stage
  service                    = "pubsub.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_iam_member" "stage_cloudbuild_service_account_user_iam" {
  provider   = google.stage
  role       = "roles/iam.serviceAccountUser"
  member     = "serviceAccount:${data.google_project.stage_project.number}@cloudbuild.gserviceaccount.com"
  depends_on = [google_project_service.stage_cloudbuild_api]
}

resource "google_project_iam_member" "stage_cloudbuild_run_admin_iam" {
  provider   = google.stage
  role       = "roles/run.admin"
  member     = "serviceAccount:${data.google_project.stage_project.number}@cloudbuild.gserviceaccount.com"
  depends_on = [google_project_service.stage_cloudbuild_api]
}

# Set up Firestore in Native Mode
# https://firebase.google.com/docs/firestore/solutions/automate-database-create#create_a_database_with_terraform
resource "google_project_service" "stage_appengine_api" {
  provider = google.stage
  service  = "appengine.googleapis.com"
}

resource "google_app_engine_application" "stage_app" {
  project = data.google_project.stage_project.project_id
  # Standard region names (e.g., for Cloud Run) are not valid for App Engine.
  # App Engine locations do not use the numeric suffix. Strip that to colocate
  # the Firestore instance with Cloud Run. (us-central1 => us-central)
  # https://cloud.google.com/appengine/docs/locations
  # https://www.terraform.io/docs/language/functions/regex.html
  location_id   = replace(trimspace(var.google_region), "/\\d+$/", "")
  database_type = "CLOUD_FIRESTORE"
  depends_on = [
    google_project_service.prod_appengine_api,
  ]
}
