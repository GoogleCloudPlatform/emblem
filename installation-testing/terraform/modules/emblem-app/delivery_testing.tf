# GCP project data
data "google_project" "ops" {
  project_id = var.ops_project_id
}

############################
# E2E Delivery testing IAM #
############################

resource "google_project_iam_member" "delivery_gae_viewer" {
  project  = var.project_id
  provider = google
  role     = "roles/appengine.appViewer"
  member   = "serviceAccount:${data.google_project.ops.number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "delivery_sa_admin" {
  project  = var.project_id
  provider = google
  role     = "roles/iam.serviceAccountAdmin"
  member   = "serviceAccount:${data.google_project.ops.number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "delivery_compute_viewer" {
  project  = var.project_id
  provider = google
  role     = "roles/compute.viewer"
  member   = "serviceAccount:${data.google_project.ops.number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "delivery_iam_reviewer" {
  project  = var.project_id
  provider = google
  role     = "roles/iam.securityReviewer"
  member   = "serviceAccount:${data.google_project.ops.number}@cloudbuild.gserviceaccount.com"
}

resource "google_storage_bucket_iam_member" "delivery_storage_admin" {
  provider = google
  role     = "roles/storage.admin"
  member   = "serviceAccount:${data.google_project.ops.number}@cloudbuild.gserviceaccount.com"
  bucket   = "${var.ops_project_id}-sessions"
}

# These `iam.securityAdmin` roles allow the target service accounts to change IAM policies.
#
# To prevent them granting arbitrary IAM roles, we use
# a `condition` clause to restrict what they can grant.
#
# See this doc page for more information on conditions:
#
#   https://cloud.google.com/iam/docs/conditions-overview
#
resource "google_project_iam_member" "delivery_storage_object_admin_granting" {
  project  = var.project_id
  provider = google
  role     = "roles/iam.securityAdmin"
  member   = "serviceAccount:${data.google_project.ops.number}@cloudbuild.gserviceaccount.com"

  condition {
    title       = "Sessions Object Admin only"
    description = "Only allow granting/revocation of the Storage Object Admin role to the Sessions bucket"
    expression  = "api.getAttribute('iam.googleapis.com/modifiedGrantsByRole', []).hasOnly(['roles/storage.objectAdmin']) && resource.type == 'storage.googleapis.com/Bucket' && resource.name.endsWith('sessions')"
  }
}

resource "google_project_iam_member" "delivery_run_admin_granting" {
  project  = var.project_id
  provider = google
  role     = "roles/iam.securityAdmin"
  member   = "serviceAccount:${data.google_project.ops.number}@cloudbuild.gserviceaccount.com"

  # Restrict which roles the Service Account can grant
  # See https://cloud.google.com/iam/docs/conditions-overview
  condition {
    title       = "Cloud Run roles only"
    description = "Only allow granting/revocation of roles relevant to Cloud Run"
    expression  = "api.getAttribute('iam.googleapis.com/modifiedGrantsByRole', []).hasOnly(['roles/run.admin', 'roles/iam.serviceAccountUser'])"
  }
}
