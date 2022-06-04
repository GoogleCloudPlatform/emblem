resource "google_cloudbuild_trigger" "web_deploy" {
  for_each = var.environment_project_ids
  project  = var.project_id
  name     = "web-deploy-${each.value}"
  pubsub_config {
    # TODO: change to reference to remote state or data source
    topic = "projects/${var.project_id}/topics/deploy-${each.value}"
  }
  approval_config {
    approval_required = true
  }
  filter = "_IMAGE_NAME.matches('website')"
  substitutions = {
    _IMAGE_NAME     = "$(body.message.attributes._IMAGE_NAME)"
    _REGION         = "$(body.message.attributes._REGION)"
    _REVISION       = "$(body.message.attributes._REVISION)"
    _SERVICE        = "website"
    _TARGET_PROJECT = each.value
    _ENV            = "${each.key}"
  }
  source_to_build {
    uri       = var.github_url
    ref       = "refs/heads/main"
    repo_type = "GITHUB"
  }

  git_file_source {
    path      = "ops/deploy.cloudbuild.yaml"
    repo_type = "GITHUB"
  }
}

# Place-holder resources

resource "null_resource" "api_deploy" {
  for_each = var.environment_project_ids
}

resource "null_resource" "web_canary" {
  for_each = var.environment_project_ids
}

resource "null_resource" "api_canary" {
  for_each = var.environment_project_ids
}
