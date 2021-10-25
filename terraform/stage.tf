resource "google_service_account" "stage_cloud_run_manager" {
  project      = data.google_project.stage_project.project_id
  account_id   = "cloud-run-manager"
  description  = "Account for deploying new revisions and controlling traffic to Cloud Run"
  display_name = "cloud-run-manager"
  provider     = google.stage
}

resource "google_pubsub_topic" "stage_canary_pubsub" {
  project  = data.google_project.stage_project.project_id
  name     = "canary"
  provider = google.stage
}

resource "google_project_service" "stage_cloudbuild_api" {
  project  = data.google_project.stage_project.project_id
  provider = google.stage
  service  = "cloudbuild.googleapis.com"
}

resource "google_project_service" "stage_firestore_api" {
  project    = data.google_project.stage_project.project_id
  provider   = google.stage
  service    = "firestore.googleapis.com"
  depends_on = [google_project_service.stage_appengine_api]
}

resource "google_project_service" "stage_run_api" {
  project  = data.google_project.stage_project.project_id
  provider = google.stage
  service  = "run.googleapis.com"
}

resource "google_project_service" "stage_pubsub_api" {
  project                    = data.google_project.stage_project.project_id
  provider                   = google.stage
  service                    = "pubsub.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_iam_member" "stage_cloudbuild_service_account_user_iam" {
  project    = data.google_project.stage_project.project_id
  provider   = google.stage
  role       = "roles/iam.serviceAccountUser"
  member     = "serviceAccount:${data.google_project.stage_project.number}@cloudbuild.gserviceaccount.com"
  depends_on = [google_project_service.stage_cloudbuild_api]
}

resource "google_project_iam_member" "stage_cloudbuild_run_admin_iam" {
  project    = data.google_project.stage_project.project_id
  provider   = google.stage
  role       = "roles/run.admin"
  member     = "serviceAccount:${data.google_project.stage_project.number}@cloudbuild.gserviceaccount.com"
  depends_on = [google_project_service.stage_cloudbuild_api]
}

# Set up Firestore in Native Mode
# https://firebase.google.com/docs/firestore/solutions/automate-database-create#create_a_database_with_terraform
resource "google_project_service" "stage_appengine_api" {
  project  = data.google_project.stage_project.project_id
  provider = google.stage
  service  = "appengine.googleapis.com"
}
