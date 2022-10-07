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
  substitutions = {
    _CONTEXT = "content-api/."
  }
  tags = []
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
  ignored_files = [
    "website/e2e-test/*",
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
  substitutions = {}
  tags          = []
}
