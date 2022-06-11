##################################
# Build & Store Container Images #
##################################
resource "google_cloudbuild_trigger" "delivery_image_push_to_main" {
  project        = var.project_id
  name           = "delivery-image-push-to-main"
  filename       = "installation-testing/builds/e2e-deployer.cloudbuild.yaml"
  included_files = ["installation-testing/builds/**"]
  description    = "Automatically rebuilds the Docker container used in installation tests."

  github {
    owner = var.repo_owner
    name  = var.repo_name
    push {
      branch = "^main$"
    }
  }

  # These properties are detected as changed if not initialized.
  # Alternately, add a lifecycle rule to ignore_changes.
  ignored_files = []
  substitutions = {}
  tags          = []
}

###########################################
# Create CI (automated testing) pipelines #
###########################################
resource "google_cloudbuild_trigger" "test_installation_nightly" {
  project     = var.project_id
  name        = "installation-e2e-nightly"
  description = "Nightly test of Emblem's installation scripts (primarily 'setup.sh')."

  pubsub_config {
    topic = data.google_pubsub_topic.nightly.id
  }

  source_to_build {
    uri       = "https://github.com/${var.repo_owner}/${var.repo_name}"
    ref       = "refs/heads/main"
    repo_type = "GITHUB"
  }

  git_file_source {
    path      = "installation-testing/builds/delivery-e2e.cloudbuild.yaml"
    repo_type = "GITHUB"
  }

  substitutions = {
    _DELIVERY_TEST_PROJECT = var.project_id
  }

  # These properties are detected as changed if not initialized.
  # Alternately, add a lifecycle rule to ignore_changes.
  ignored_files  = []
  included_files = []
  tags           = []
}
