# GCP project data
data "google_project" "ops" {
  project_id = var.project_id
}

############################
# E2E Delivery testing IAM #
############################

resource "google_project_iam_member" "delivery_ar_admin" {
  project  = var.project_id
  provider = google
  role     = "roles/artifactregistry.admin"
  member   = "serviceAccount:${data.google_project.ops.number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "delivery_secret_admin" {
  project  = var.project_id
  provider = google
  role     = "roles/secretmanager.admin"
  member   = "serviceAccount:${data.google_project.ops.number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "delivery_scheduler_admin" {
  project  = var.project_id
  provider = google
  role     = "roles/cloudscheduler.admin"
  member   = "serviceAccount:${data.google_project.ops.number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "delivery_pubsub_editor" {
  project  = var.project_id
  provider = google
  role     = "roles/pubsub.editor"
  member   = "serviceAccount:${data.google_project.ops.number}@cloudbuild.gserviceaccount.com"
}

# This role allows the target service account to change IAM policies.
#
# To prevent it granting arbitrary IAM roles, we use
# a `condition` clause to restrict what it can grant.
#
# Namely, the service account can ONLY grant
# or revoke the `roles/pubsub.publisher` role.
#
# See this doc page for more information on conditions:
#
#   https://cloud.google.com/iam/docs/conditions-overview
#
resource "google_project_iam_member" "delivery_pubsub_publisher_granting" {
  project  = var.project_id
  provider = google
  role     = "roles/iam.securityAdmin"
  member   = "serviceAccount:${data.google_project.ops.number}@cloudbuild.gserviceaccount.com"

  # Restrict which roles the Service Account can grant
  # See https://cloud.google.com/iam/docs/conditions-overview
  condition {
    title       = "Pub/Sub Publisher only"
    description = "Only allow granting/revocation of the roles/pubsub.publisher role"
    expression  = "api.getAttribute('iam.googleapis.com/modifiedGrantsByRole', []).hasOnly(['roles/pubsub.publisher'])"
  }
}
