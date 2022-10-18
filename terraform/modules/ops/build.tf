# Build & Store Container Images

resource "google_cloudbuild_trigger" "api_new_build" {
  project        = var.project_id
  count          = var.setup_cd_system ? 1 : 0
  name           = "api-new-build"
  filename       = "ops/api-build.cloudbuild.yaml"
  included_files = ["content-api/**"]
  description    = "Triggers on every change to main branch in content-api directory. Initiates content-api image build."
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

resource "google_cloudbuild_trigger" "web_new_build" {
  project     = var.project_id
  count       = var.setup_cd_system ? 1 : 0
  name        = "web-new-build"
  filename    = "ops/web-build.cloudbuild.yaml"
  description = "Triggers on every change to main branch in website directory. Initiates website image build."
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
