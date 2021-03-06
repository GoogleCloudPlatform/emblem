resource "time_sleep" "wait_for_cloud_build_service" {
  create_duration = "20s"
  depends_on = [
    google_project_service.emblem_ops_services
  ]
}

resource "google_cloudbuild_trigger" "api_unit_tests_build_trigger" {
  project        = var.project_id
  count          = var.deploy_triggers ? 1 : 0
  name           = "api-unit-tests"
  filename       = "ops/unit-tests.cloudbuild.yaml"
  included_files = ["content-api/**"]
  substitutions = {
    _DIR             = "content-api"
    _SERVICE_ACCOUNT = format("restricted-test-identity@%s.iam.gserviceaccount.com", var.project_id)
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

resource "google_cloudbuild_trigger" "api_push_to_main_build_trigger" {
  project        = var.project_id
  count          = var.deploy_triggers ? 1 : 0
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
}

resource "google_cloudbuild_trigger" "website_unit_tests_build_trigger" {
  project        = var.project_id
  count          = var.deploy_triggers ? 1 : 0
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
  depends_on = [
    time_sleep.wait_for_cloud_build_service
  ]
}

resource "google_cloudbuild_trigger" "web_push_to_main_build_trigger" {
  project  = var.project_id
  count    = var.deploy_triggers ? 1 : 0
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
}

resource "google_cloudbuild_trigger" "e2e_runner_push_to_main_build_trigger" {
  project  = var.project_id
  count    = var.deploy_triggers ? 1 : 0
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
}

resource "google_cloudbuild_trigger" "e2e_runner_nightly_build_trigger" {
  project = var.project_id
  count   = var.deploy_triggers ? 1 : 0
  name    = "e2e-runner-nightly"

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
}
