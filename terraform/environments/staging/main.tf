data "google_pubsub_topic" "deploy_trigger" {
  name    = var.deploy_trigger_topic
  project = var.ops_project_id
}

module "emblem_staging" {
  source                  = "../../modules/emblem-app"
  project_id              = var.project_id
  ops_project_id          = var.ops_project_id
  region                  = var.region
  environment             = "staging"
  enable_apis             = var.enable_apis
  deploy_session_bucket   = var.deploy_session_bucket
  session_bucket_ttl_days = var.session_bucket_ttl_days
  setup_cd_system         = var.setup_cd_system
  repo_owner              = var.repo_owner
  repo_name               = var.repo_name
  deploy_trigger_topic_id = data.google_pubsub_topic.deploy_trigger.id
  gcr_pubsub_format       = true
  require_deploy_approval = false
}

// Set up Website E2E tests against a staging environment
module "emblem_staging_website_e2e_tests" {
  source          = "../../modules/website-e2e-test"
  project_id      = var.project_id
  region          = var.region
  repo_owner      = var.repo_owner
  repo_name       = var.repo_name

  // Temporary variables; used until Website
  // E2E tests are integrated with setup.sh
  // TODO: adjust these variables once integration is complete.
  count           = 0
  content_api_url = ""
}
