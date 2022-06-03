module "emblem_ops" {
  source                  = "../../modules/ops"
  project_id              = var.project_id
  region                  = var.region
  repo_owner              = var.repo_owner
  deploy_triggers         = var.deploy_triggers
  repo_name               = var.repo_name
  environment_project_ids = var.environment_project_ids
}
