# Testing Resources

####################
# Testing Fixtures #
####################

resource "google_service_account" "test_user" {
  project      = var.project_id
  account_id   = "test-user"
  display_name = "Test Account [User]"
  description  = "Mock user account for unit and integration tests."
}

resource "google_service_account" "test_approver" {
  project      = var.project_id
  account_id   = "test-approver"
  display_name = "Test Account [Approver]"
  description  = "Mock approver account for unit and integration tests."
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

###################
# Website Testing #
###################

resource "google_cloudbuild_trigger" "web_e2e_test" {
  project     = var.project_id
  count       = var.setup_cd_system ? 1 : 0
  name        = "web-e2e-test"
  filename    = "ops/web-e2e.cloudbuild.yaml"
  description = "Triggers on every pull request with website directory changes. Runs system tests."
  included_files = [
    "website/**",
    "ops/web-e2e.cloudbuild.yaml"
  ]
  substitutions = {
    _DIR        = "website"
    _EMBLEM_URL = "http://localhost:8080"
    _PROJECT    = data.google_project.target_project.project_id
  }
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

######################
# End-to-end Testing #
######################

# TODO: Terraform will always think these resources will change due to 
# the filename parameter, which is not required, but still populated by
# the API.  Investigate work-around.
resource "google_cloudbuild_trigger" "e2e_nightly_tests" {
  project     = var.project_id
  count       = 0
  name        = "e2e-nightly-tests"
  description = "Triggers via nightly Cloud Scheduler. Builds e2e container image."
  pubsub_config {
    topic = google_pubsub_topic.nightly.id
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

resource "google_cloudbuild_trigger" "e2e_testing_build_runner" {
  project     = var.project_id
  count       = 0
  name        = "e2e-runner-push-to-main"
  filename    = "ops/e2e-runner-build.cloudbuild.yaml"
  description = "Triggers on every change to main in the website/e2e-test directory. Builds e2e container image."
  included_files = [
    "website/e2e-test/*",
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
