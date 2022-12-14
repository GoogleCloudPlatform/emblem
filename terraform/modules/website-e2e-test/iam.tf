# IAM permissions

locals {
  # Cloud build service account roles
  pubsub_iam_roles_list = [
    "roles/cloudscheduler.admin"
  ]
}

resource "google_project_iam_member" "web_e2e_iam_members" {
  project  = var.project_id
  provider = google
  for_each = toset(local.pubsub_iam_roles_list)
  role     = each.key
  member   = "serviceAccount:emblem-terraformer@${var.project_id}.iam.gserviceaccount.com"
}
