data "terraform_remote_state" "ops" {
  backend = "local"
  config = {
    path = "../terraform.tfstate"
  }
}

resource "google_cloudbuild_trigger" "api_unit_tests_build_trigger" {
  project        = var.google_ops_project_id
  name           = "api-unit-tests"
  filename       = "ops/unit-tests.cloudbuild.yaml"
  included_files = ["content-api/**"]
  substitutions = {
    _DIR             = "content-api"
    _SERVICE_ACCOUNT = "restricted-test-identity@emblem-ops.iam.gserviceaccount.com"
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

resource "google_cloudbuild_trigger" "api_push_to_main_build_trigger" {
  project        = var.google_ops_project_id
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
}

resource "google_cloudbuild_trigger" "website_unit_tests_build_trigger" {
  project        = var.google_ops_project_id
  name           = "website-unit-tests"
  filename       = "ops/unit-tests.cloudbuild.yaml"
  included_files = ["website/**"]
  substitutions = {
    _DIR = "website"
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

resource "google_cloudbuild_trigger" "web_push_to_main_build_trigger" {
  project  = var.google_ops_project_id
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
}

resource "google_cloudbuild_trigger" "e2e_runner_push_to_main_build_trigger" {
  project  = var.google_ops_project_id
  name     = "e2e-runner-push-to-main"
  filename = "ops/e2e-runner-build.cloudbuild.yaml"
  included_files = [
    "website/*",
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
}
