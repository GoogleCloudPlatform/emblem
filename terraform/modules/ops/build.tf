# Build & Store Container Images

resource "google_cloudbuild_trigger" "api_push_to_main" {
  project        = var.project_id
  count          = var.setup_cd_system ? 1 : 0
  name           = "api-push-to-main"
  filename       = "ops/api-build.cloudbuild.yaml"
  included_files = ["content-api/**"]
  github {
    owner = var.repo_owner
    name  = var.repo_name
    push {
      branch = "^main$"
    }
  }
  depends_on = [
    time_sleep.wait_for_cloud_build_service
  ]

  # These properties are detected as changed if not initialized.
  # Alternately, add a lifecycle rule to ignore_changes.
  ignored_files = []
  substitutions = {}
  tags          = []
}

resource "google_cloudbuild_trigger" "web_push_to_main" {
  project  = var.project_id
  count    = var.setup_cd_system ? 1 : 0
  name     = "web-push-to-main"
  filename = "ops/web-build.cloudbuild.yaml"
  included_files = [
    "website/*",
    "website/*/*",
    "client-libs/python/*"
  ]
  github {
    owner = var.repo_owner
    name  = var.repo_name
    push {
      branch = "^main$"
    }
  }
  depends_on = [
    time_sleep.wait_for_cloud_build_service
  ]

  # These properties are detected as changed if not initialized.
  # Alternately, add a lifecycle rule to ignore_changes.
  ignored_files = []
  substitutions = {}
  tags          = []
}

resource "google_cloudbuild_trigger" "e2e_runner_push_to_main" {
  project  = var.project_id
  count    = var.setup_cd_system ? 1 : 0
  name     = "e2e-runner-push-to-main"
  filename = "ops/e2e-runner-build.cloudbuild.yaml"
  included_files = [
    "website/e2e-test/Dockerfile",
  ]
  github {
    owner = var.repo_owner
    name  = var.repo_name
    # NOTE: this image will ONLY be updated when a PR
    # is merged into `main`. "Presubmit only" changes
    # within a non-merged PR will NOT be included!
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