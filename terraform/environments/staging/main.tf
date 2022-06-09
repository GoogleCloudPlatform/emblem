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
}
