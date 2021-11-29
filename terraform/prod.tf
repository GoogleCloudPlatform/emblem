resource "google_service_account" "prod_cloud_run_manager" {
  project      = data.google_project.prod_project.project_id
  account_id   = "cloud-run-manager"
  description  = "Account for deploying new revisions and controlling traffic to Cloud Run"
  display_name = "cloud-run-manager"
  provider     = google.prod
}

resource "google_pubsub_topic" "prod_canary_pubsub" {
  project  = data.google_project.prod_project.project_id
  name     = "canary"
  provider = google.prod
}

resource "google_project_service" "prod_cloudbuild_api" {
  project  = data.google_project.prod_project.project_id
  provider = google.prod
  service  = "cloudbuild.googleapis.com"
}

resource "google_project_service" "prod_firestore_api" {
  project    = data.google_project.prod_project.project_id
  provider   = google.prod
  service    = "firestore.googleapis.com"
  depends_on = [google_project_service.prod_appengine_api]
}

resource "google_project_service" "prod_run_api" {
  project  = data.google_project.prod_project.project_id
  provider = google.prod
  service  = "run.googleapis.com"
}

resource "google_project_service" "prod_pubsub_api" {
  project                    = data.google_project.prod_project.project_id
  provider                   = google.prod
  service                    = "pubsub.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_iam_member" "prod_cloudbuild_service_account_user_iam" {
  project    = data.google_project.prod_project.project_id
  provider   = google.prod
  role       = "roles/iam.serviceAccountUser"
  member     = "serviceAccount:${data.google_project.prod_project.number}@cloudbuild.gserviceaccount.com"
  depends_on = [google_project_service.prod_cloudbuild_api]
}

resource "google_project_iam_member" "prod_cloudbuild_run_admin_iam" {
  project    = data.google_project.prod_project.project_id
  provider   = google.prod
  role       = "roles/run.admin"
  member     = "serviceAccount:${data.google_project.prod_project.number}@cloudbuild.gserviceaccount.com"
  depends_on = [google_project_service.prod_cloudbuild_api]
}

# Set up Firestore in Native Mode
# https://firebase.google.com/docs/firestore/solutions/automate-database-create#create_a_database_with_terraform
resource "google_project_service" "prod_appengine_api" {
  project  = data.google_project.prod_project.project_id
  provider = google.prod
  service  = "appengine.googleapis.com"
}

resource "google_app_engine_application" "prod_app" {
  project = data.google_project.prod_project.project_id
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

resource "google_storage_bucket" "sessions_prod" {
  project       = data.google_project.prod_project.project_id
  name          = "${data.google_project.prod_project.project_id}-sessions"
  force_destroy = true
  location      = var.google_region

  # Delete files after a certain time
  # (These buckets will contain end-user data, so periodic deletion is a best practice.)
  lifecycle_rule {
    condition {
      age = var.session_bucket_ttl
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_project_iam_member" "ops_secret_access_iam_prod" {
  project    = data.google_project.ops_project.project_id
  provider   = google.ops
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:service-${data.google_project.prod_project.number}@serverless-robot-prod.iam.gserviceaccount.com"
  depends_on = [google_project_service.prod_run_api]
}
