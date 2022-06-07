data "google_project" "app" {
  project_id = var.project_id
}

data "google_project" "ops" {
  project_id = var.ops_project_id
}

# The following will check if a app engine default service account exists
# If it already does, Terraform will not create an Appengine App
# This is a work around for Terraform being unable to truely destroy
# an app engine application
# Issue: https://github.com/hashicorp/terraform-provider-google/issues/10351#issuecomment-1116555590
data "google_app_engine_default_service_account" "default" {
  project = var.project_id
}

resource "google_app_engine_application" "main" {
  count         = data.google_app_engine_default_service_account.default.unique_id == null ? 1 : 0
  project       = var.project_id
  location_id   = replace(trimspace(var.region), "/\\d+$/", "")
  database_type = "CLOUD_FIRESTORE"
  depends_on = [
    google_project_service.emblem_app_services
  ]
}

# TODO: narrow scope of IAM permission to only necessary service accounts rather than whole project
resource "google_project_iam_member" "cloudbuild_role_service_account_user" {
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${data.google_project.ops.number}@cloudbuild.gserviceaccount.com"
  project = var.project_id
}

resource "google_project_iam_member" "cloudbuild_role_run_admin" {
  role    = "roles/run.admin"
  member  = "serviceAccount:${data.google_project.ops.number}@cloudbuild.gserviceaccount.com"
  project = var.project_id
}

###
# Pipeline Orchestration
###

resource "google_pubsub_topic" "canary" {
  name    = "canary-${var.project_id}"
  project = var.ops_project_id
}

resource "google_pubsub_topic" "deploy" {
  name    = "deploy-${var.project_id}"
  project = var.ops_project_id
}

# Define user session storage bucket.
# Objects created in this bucket represent a new user session.
# A user may have more than one session, representing different authenticated applications/devices.
resource "google_storage_bucket" "sessions" {
  name                        = "${var.project_id}-sessions"
  project                     = var.project_id
  uniform_bucket_level_access = true
  force_destroy               = true
  location                    = var.region
  # These buckets will contain end-user data, so periodic deletion is a best practice.
  # See: https://cloud.google.com/storage/docs/lifecycle
  lifecycle_rule {
    condition {
      age = var.session_bucket_ttl_days
    }
    action {
      type = "Delete"
    }
  }
  
  # Allow Terraform runs to opt-out of creating this bucket.
  # (This is necessary for some of Emblem's automated tests.)
  count                       = variable.deploy_session_bucket ? 1 : 0
}

resource "google_storage_bucket_iam_member" "sessions-iam" {
  bucket = google_storage_bucket.sessions.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.website_manager.email}"
}
