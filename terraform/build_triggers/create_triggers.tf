resource "google_cloudbuild_trigger" "github_trigger" {
  name    = "web-push-to-main"
  project = data.google_project.ops_project.project_id

  github {
    owner = var.repo_owner
    name  = var.repo_name

    pull_request {
      branch = "^main$"
    }
  }

  filename = "ops/build.cloudbuild.yaml"

  included_files = ["website/*"]

  substitutions = {
    _DIR = "website"
  }
}

resource "google_cloudbuild_trigger" "pubsub_trigger" {
  name    = "web-deploy-staging"
  project = data.google_project.ops_project.project_id

  pubsub_config {
    topic = "projects/${data.google_project.ops_project.project_id}/topics/gcr"
  }

  filename = "ops/deploy.cloudbuild.yaml"

  included_files = ["website/*"]

  substitutions = {
    _IMAGE_NAME     = "$(body.message.data.tag)"
    _REVISION       = "$(body.message.messageId)"
    _REGION         = var.google_region
    _SERVICE        = "website"
    _TARGET_PROJECT = data.google_project.ops_project.project_id
  }
}
