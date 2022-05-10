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
}

resource "google_storage_bucket_iam_member" "sessions-iam" {
  bucket = google_storage_bucket.sessions.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.website_manager.email}"
}
