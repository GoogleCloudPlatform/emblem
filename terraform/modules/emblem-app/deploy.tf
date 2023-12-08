######################
# Service Deployment #
######################

## Pipeline Orchestration

# Canary Topic
#
# Used by Cloud Build to signal a Cloud Run revision is ready to receive a
# higher percentage of service traffic. It carries messages for all services.
#
# Publisher:
# - https://github.com/GoogleCloudPlatform/emblem/blob/main/ops/deploy.cloudbuild.yaml
# - https://github.com/GoogleCloudPlatform/emblem/blob/main/ops/canary.cloudbuild.yaml
# Subscriber:
# - google_cloudbuild_trigger.api_canary in deploy.tf
# - google_cloudbuild_trigger.web_canary in deploy.tf
resource "google_pubsub_topic" "canary" {
  name    = "canary-${var.environment}"
  project = var.ops_project_id
}

# Deploy Completed Topic
#
# Used by the Cloud Build canary build that completes 100% rollout of a service
# to signal that rollout has completed.
#
# Publisher:
# - https://github.com/GoogleCloudPlatform/emblem/blob/main/ops/canary.cloudbuild.yaml
# Subscriber:
# - The default configuration of prod google_cloudbuild_trigger.api_deploy and
#   google_cloudbuild_trigger.web_deploy uses this to respond to staging rollout
#   completion. Cloud Build will wait for human approval.
resource "google_pubsub_topic" "deploy-completed" {
  name    = "deploy-completed-${var.environment}"
  project = var.ops_project_id
}

## Cloud Build permissions to deploy Cloud Run services to this environment.

# TODO: narrow scope of IAM permission to only necessary service accounts rather than whole project
resource "google_project_iam_member" "cloudbuild_role_service_account_user" {
  count   = var.setup_cd_system ? 1 : 0
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${data.google_project.ops.number}@cloudbuild.gserviceaccount.com"
  project = var.project_id
}

resource "google_project_iam_member" "cloudbuild_role_run_admin" {
  count   = var.setup_cd_system ? 1 : 0
  role    = "roles/run.admin"
  member  = "serviceAccount:${data.google_project.ops.number}@cloudbuild.gserviceaccount.com"
  project = var.project_id
}

## Start Deploy ##

resource "google_cloudbuild_trigger" "web_deploy" {
  count       = var.setup_cd_system ? 1 : 0
  project     = var.ops_project_id
  name        = "web-deploy-${var.environment}"
  description = "Triggers on any new website build to Artifact Registry. Begins container deployment for staging/prod environment."
  pubsub_config {
    topic = var.deploy_trigger_topic_id
  }
  approval_config {
    approval_required = var.require_deploy_approval
  }
  filter   = "_IMAGE_NAME.matches('website')"
  filename = "ops/deploy.cloudbuild.yaml"
  substitutions = {
    _BODY           = "$(body)"
    _ENV            = var.environment
    _IMAGE_NAME     = var.gcr_pubsub_format ? "$(body.message.data.tag)" : "$(body.message.attributes._IMAGE_NAME)"
    _REGION         = var.region
    _REVISION       = var.gcr_pubsub_format ? "$(body.message.messageId)" : "$(body.message.attributes._REVISION)"
    _SERVICE        = "website"
    _TARGET_PROJECT = var.project_id
  }
  source_to_build {
    uri       = format("https://github.com/%s/%s", var.repo_owner, var.repo_name)
    ref       = "refs/heads/main"
    repo_type = "GITHUB"
  }
}

resource "google_cloudbuild_trigger" "api_deploy" {
  count       = var.setup_cd_system ? 1 : 0
  project     = var.ops_project_id
  name        = "api-deploy-${var.environment}"
  description = "Triggers on any new content-api build to Artifact Registry. Begins container deployment for staging/prod environment."
  pubsub_config {
    topic = var.deploy_trigger_topic_id
  }
  approval_config {
    approval_required = var.require_deploy_approval
  }
  filter   = "_IMAGE_NAME.matches('content-api')"
  filename = "ops/deploy.cloudbuild.yaml"
  substitutions = {
    _BODY           = "$(body)"
    _ENV            = var.environment
    _IMAGE_NAME     = var.gcr_pubsub_format ? "$(body.message.data.tag)" : "$(body.message.attributes._IMAGE_NAME)"
    _REGION         = var.region
    _REVISION       = var.gcr_pubsub_format ? "$(body.message.messageId)" : "$(body.message.attributes._REVISION)"
    _SERVICE        = "content-api"
    _TARGET_PROJECT = var.project_id
  }
  source_to_build {
    uri       = format("https://github.com/%s/%s", var.repo_owner, var.repo_name)
    ref       = "refs/heads/main"
    repo_type = "GITHUB"
  }
}

## Canary Traffic ##

resource "google_cloudbuild_trigger" "web_canary" {
  count       = var.setup_cd_system ? 1 : 0
  project     = var.ops_project_id
  name        = "web-canary-${var.environment}"
  description = "Triggers on initial environment (staging, prod) deployment for website container. Performs general health check before increasing traffic."
  pubsub_config {
    topic = google_pubsub_topic.canary.id
  }
  approval_config {
    approval_required = false
  }
  filter   = format("_SERVICE.matches('%s')", "website")
  filename = "ops/canary.cloudbuild.yaml"
  substitutions = {
    _BODY           = "$(body)"
    _ENV            = var.environment
    _IMAGE_NAME     = "$(body.message.attributes._IMAGE_NAME)"
    _REGION         = var.region
    _REVISION       = "$(body.message.attributes._REVISION)"
    _SERVICE        = "$(body.message.attributes._SERVICE)"
    _TARGET_PROJECT = var.project_id
    _TRAFFIC        = "$(body.message.attributes._TRAFFIC)"
  }
  source_to_build {
    uri       = format("https://github.com/%s/%s", var.repo_owner, var.repo_name)
    ref       = "refs/heads/main"
    repo_type = "GITHUB"
  }
}

resource "google_cloudbuild_trigger" "api_canary" {
  count       = var.setup_cd_system ? 1 : 0
  project     = var.ops_project_id
  name        = "api-canary-${var.environment}"
  description = "Triggers on initial environment (staging, prod) deployment for content-api container. Performs general health check before increasing traffic."
  pubsub_config {
    topic = google_pubsub_topic.canary.id
  }
  approval_config {
    approval_required = false
  }
  filter   = format("_SERVICE.matches('%s')", "content-api")
  filename = "ops/canary.cloudbuild.yaml"
  substitutions = {
    _BODY           = "$(body)"
    _ENV            = var.environment
    _IMAGE_NAME     = "$(body.message.attributes._IMAGE_NAME)"
    _REGION         = var.region
    _REVISION       = "$(body.message.attributes._REVISION)"
    _SERVICE        = "$(body.message.attributes._SERVICE)"
    _TARGET_PROJECT = var.project_id
    _TRAFFIC        = "$(body.message.attributes._TRAFFIC)"
    _TRAFFIC_INCREMENT = var.traffic_increment
  }
  source_to_build {
    uri       = format("https://github.com/%s/%s", var.repo_owner, var.repo_name)
    ref       = "refs/heads/main"
    repo_type = "GITHUB"
  }
}
