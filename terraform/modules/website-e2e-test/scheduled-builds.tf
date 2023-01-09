# Build triggers

###########################
# Build testing container #
###########################
resource "google_pubsub_topic" "testing_web_e2e_build_container_topic" {
  name    = "testing-web-e2e-build-container-topic"
  project = var.project_id
}

resource "google_cloud_scheduler_job" "testing_web_e2e_build_container_job" {
  project     = var.project_id
  name        = "testing-web-e2e-build-container-job"
  description = "This job builds the Website E2E testing container on a nightly basis."
  region      = var.region
  schedule    = "0 2 * * *"
  pubsub_target {
    topic_name = google_pubsub_topic.testing_web_e2e_build_container_topic.id
    data       = base64encode("not empty")
  }
  depends_on = [
    google_pubsub_topic.testing_web_e2e_build_container_topic
  ]
}

#################
# Run E2E tests #
#################
resource "google_pubsub_topic" "testing_web_e2e_run_tests_topic" {
  name    = "testing-web-e2e-run-tests-topic"
  project = var.project_id
}

resource "google_cloud_scheduler_job" "testing_web_e2e_run_tests_job" {
  project     = var.project_id
  name        = "testing-web-e2e-run-tests-job"
  description = "This job runs the Website E2E tests  on a nightly basis."
  region      = var.region
  schedule    = "0 3 * * *"
  pubsub_target {
    topic_name = google_pubsub_topic.testing_web_e2e_run_tests_topic.id
    data       = base64encode("not empty")
  }
  depends_on = [
    google_pubsub_topic.testing_web_e2e_run_tests_topic
  ]
}
