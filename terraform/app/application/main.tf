data "google_project" "main" {
  project_id = var.google_project_id
}

###
# Enable Google Cloud Services
###

# Set up Firestore in Native Mode
# https://firebase.google.com/docs/firestore/solutions/automate-database-create#create_a_database_with_terraform
resource "google_project_service" "appengine" {
  service  = "appengine.googleapis.com"
  project  = data.google_project.main.project_id
  provider = google
}

resource "google_project_service" "firestore" {
  service    = "firestore.googleapis.com"
  project    = data.google_project.main.project_id
  provider   = google
  depends_on = [google_project_service.appengine]
}

resource "google_project_service" "run" {
  service  = "run.googleapis.com"
  project  = data.google_project.main.project_id
  provider = google
}

###
# IAM & Access Control
###

# Create a Cloud Run deployer service account.
# TODO(#254): Move to ops and replace with service identity
resource "google_service_account" "cloud_run_manager" {
  account_id   = "cloud-run-manager"
  description  = "Deploys new revisions and controls traffic to Cloud Run."
  display_name = "cloud-run-manager"
  project      = data.google_project.main.project_id
  provider     = google
}

resource "google_service_account" "website_manager" {
  account_id   = "website-manager"
  description  = "Manages website deployments on Cloud Run."
  display_name = "website-manager"
  project      = data.google_project.main.project_id
  provider     = google
}

resource "google_service_account" "api_manager" {
  account_id   = "api-manager"
  description  = "Manages API deployments on Cloud Run."
  display_name = "api-manager"
  project      = data.google_project.main.project_id
  provider     = google
}

###
# Storage & Databases
###

# Create a Firestore instance in native mode, in our chosen location.
# This is currently managed as a secondary operation of App Engine instance creation.
# Related: https://github.com/GoogleCloudPlatform/emblem/issues/217
# Related: https://github.com/GoogleCloudPlatform/emblem/issues/224
resource "google_app_engine_application" "main" {
  # Standard region names (e.g., for Cloud Run) are not valid for App Engine.
  # App Engine locations do not use the numeric suffix. Strip that to colocate
  # the Firestore instance with Cloud Run. (us-central1 => us-central)
  # https://cloud.google.com/appengine/docs/locations
  # https://www.terraform.io/docs/language/functions/regex.html
  location_id   = replace(trimspace(var.region), "/\\d+$/", "")
  database_type = "CLOUD_FIRESTORE"

  project  = data.google_project.main.project_id
  provider = google
  depends_on = [
    # Service may not be ready.
    google_project_service.appengine,
  ]
}

# Define user session storage bucket.
# Objects created in this bucket represent a new user session.
# A user may have more than one session, representing different authenticated applications/devices.
resource "google_storage_bucket" "sessions" {
  name                        = "${data.google_project.main.project_id}-sessions"
  force_destroy               = true
  uniform_bucket_level_access = true
  location                    = var.region

  # Delete files after configured time.
  # (These buckets will contain end-user data, so periodic deletion is a best practice.)
  # https://cloud.google.com/storage/docs/lifecycle
  lifecycle_rule {
    condition {
      age = var.session_bucket_ttl
    }
    action {
      type = "Delete"
    }
  }

  project  = data.google_project.main.project_id
  provider = google
}

resource "google_storage_bucket_iam_member" "sessions-iam" {
  bucket = google_storage_bucket.sessions.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.website_manager.email}"
}
