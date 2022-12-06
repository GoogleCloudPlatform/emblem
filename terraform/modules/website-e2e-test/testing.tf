# Test triggers + resources

resource "google_cloudbuild_trigger" "testing_web_e2e_run_tests_trigger" {
  project     = var.project_id
  name        = "testing-web-e2e-run-tests-trigger"
  filename    = "ops/web-e2e.cloudbuild.yaml"
  description = "Triggers on every pull request with website directory changes. Runs end-to-end tests for the Website component."
  included_files = [
    "website/**",
    "ops/web-e2e.cloudbuild.yaml",
    "terraform/modules/website-e2e-test/**"
  ]
  substitutions = {
    _DIR            = "website"
    _EMBLEM_URL     = "http://localhost:8080"
    _EMBLEM_API_URL = var.content_api_url
    _PROJECT        = var.project_id
  }
  github {
    owner = var.repo_owner
    name  = var.repo_name
    pull_request {
      branch          = "^main$"
      comment_control = "COMMENTS_ENABLED_FOR_EXTERNAL_CONTRIBUTORS_ONLY"
    }
  }
}
