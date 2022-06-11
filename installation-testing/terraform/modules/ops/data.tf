data "google_project" "ops" {
  project_id = var.project_id
}

data "google_pubsub_topic" "nightly" {
  name     = var.nightly_topic_id
  project  = var.project_id
  provider = google
}
