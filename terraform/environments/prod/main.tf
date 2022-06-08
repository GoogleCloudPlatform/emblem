module "emblem_prod" {
  source                  = "../../modules/emblem-app"
  project_id              = var.project_id
  ops_project_id          = var.ops_project_id
  region                  = var.region
  enable_apis             = var.enable_apis
  deploy_session_bucket   = var.deploy_session_bucket
  session_bucket_ttl_days = var.session_bucket_ttl_days
}
