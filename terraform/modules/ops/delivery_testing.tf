############################
# E2E Delivery testing IAM #
############################

resource "google_project_iam_member" "delivery_ar_admin" {
  project  = var.project_id
  provider = google
  role     = "roles/artifactregistry.admin"
  member   = "serviceAccount:${data.google_project.target_project.number}@cloudbuild.gserviceaccount.com"

  depends_on = [
    google_project_service.emblem_ops_services
  ]
}

resource "google_project_iam_member" "delivery_secret_admin" {
  project  = var.project_id
  provider = google
  role     = "roles/secretmanager.admin"
  member   = "serviceAccount:${data.google_project.target_project.number}@cloudbuild.gserviceaccount.com"

  depends_on = [
    google_project_service.emblem_ops_services
  ]
}

resource "google_project_iam_member" "delivery_scheduler_admin" {
  project  = var.project_id
  provider = google
  role     = "roles/cloudscheduler.admin"
  member   = "serviceAccount:${data.google_project.target_project.number}@cloudbuild.gserviceaccount.com"

  depends_on = [
    google_project_service.emblem_ops_services
  ]
}

resource "google_project_iam_member" "delivery_pubsub_editor" {
  project  = var.project_id
  provider = google
  role     = "roles/pubsub.editor"
  member   = "serviceAccount:${data.google_project.target_project.number}@cloudbuild.gserviceaccount.com"

  depends_on = [
    google_project_service.emblem_ops_services
  ]
}

resource "google_project_iam_member" "delivery_pubsub_publisher_granting" {
  project  = var.project_id
  provider = google
  role     = "roles/iam.securityAdmin"
  member   = "serviceAccount:${data.google_project.target_project.number}@cloudbuild.gserviceaccount.com"

  depends_on = [
    google_project_service.emblem_ops_services
  ]

  # Restrict which roles the Service Account can grant
  # See https://cloud.google.com/iam/docs/conditions-overview
  condition {
    title       = "Pub/Sub Publisher only"
    description = "Only allow granting/revocation of the roles/pubsub.publisher role"
    expression  = "api.getAttribute('iam.googleapis.com/modifiedGrantsByRole', []).hasOnly(['roles/pubsub.publisher'])"
  }
}
