module "emblem_staging" {
  source                  = "../../modules/emblem-app"
  project_id              = var.project_id
  ops_project_id          = var.ops_project_id
  region                  = var.region
  enable_apis             = var.enable_apis
  session_bucket_ttl_days = var.session_bucket_ttl_days
}
