resource "google_cloudbuild_trigger" "api_unit_tests_build_trigger" {
  name = "api-unit-tests"
  filename = "ops/unit-tests.cloudbuild.yaml"
  included_files = ["content-api/**"]
  substitutions = {
    _DIR = "content-api"
    _SERVICE_ACCOUNT = "restricted-test-identity@emblem-ops.iam.gserviceaccount.com"
  }
  github {
    owner = "GoogleCloudPlatform"
    name = "emblem"
    pull_request {
      branch = "^main$"
      comment_control="COMMENTS_ENABLED_FOR_EXTERNAL_CONTRIBUTORS_ONLY"
    }
  }
}

resource "google_cloudbuild_trigger" "api_push_to_main_build_trigger" {
  name = "api-push-to-main"
  filename = "ops/api-build.cloudbuild.yaml"
  included_files = ["content-api/**"]
  github {
    owner = "GoogleCloudPlatform"
    name = "emblem"
    push {
      branch = "^main$"
    }
  }
}
