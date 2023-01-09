# Testing Resources

####################
# Testing Fixtures #
####################

resource "google_service_account" "test_user" {
  project      = var.project_id
  account_id   = "test-user"
  display_name = "Test Account [User]"
  description  = "Mock user account for unit and integration tests."
  depends_on = [
    time_sleep.wait_for_iam_service
  ]
}

resource "google_service_account" "test_approver" {
  project      = var.project_id
  account_id   = "test-approver"
  display_name = "Test Account [Approver]"
  description  = "Mock approver account for unit and integration tests."
  depends_on = [
    time_sleep.wait_for_iam_service
  ]
}

#######################
# Content API Testing #
#######################

resource "google_cloudbuild_trigger" "api_unit_tests" {
  project        = var.project_id
  count          = var.setup_cd_system ? 1 : 0
  name           = "api-unit-tests"
  filename       = "ops/unit-tests.cloudbuild.yaml"
  included_files = ["content-api/**"]
  substitutions = {
    _DIR             = "content-api"
    _SERVICE_ACCOUNT = google_service_account.test_user.email
  }
  description = "Triggers on every pull request with content-api directory changes. Runs api unit tests."
  github {
    owner = var.repo_owner
    name  = var.repo_name
    pull_request {
      branch          = "^main$"
      comment_control = "COMMENTS_ENABLED_FOR_EXTERNAL_CONTRIBUTORS_ONLY"
    }
  }
  depends_on = [
    time_sleep.wait_for_cloud_build_service
  ]
}
