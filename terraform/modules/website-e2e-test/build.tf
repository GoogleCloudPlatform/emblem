# Build & Store Container Images

# TODO: Terraform will always think these resources will change due to 
# the filename parameter, which is not required, but still populated by
# the API.  Investigate work-around.
resource "google_cloudbuild_trigger" "testing_web_e2e_build_container_trigger" {
  project     = var.project_id
  count       = 0
  name        = "testing-web-e2e-build-container-trigger"
  description = "Triggers via nightly Cloud Scheduler. Builds container image used to run E2E website tests."
  pubsub_config {
    topic = google_pubsub_topic.testing_web_e2e_build_container_topic.id
  }

  source_to_build {
    uri       = "https://github.com/${var.repo_owner}/${var.repo_name}"
    ref       = "refs/heads/main"
    repo_type = "GITHUB"
  }

  git_file_source {
    path      = "ops/e2e-runner-build.cloudbuild.yaml"
    repo_type = "GITHUB"
  }

  # These properties are detected as changed if not initialized.
  # Alternately, add a lifecycle rule to ignore_changes.
  ignored_files  = []
  included_files = []
  substitutions  = {}
  tags           = []
}
