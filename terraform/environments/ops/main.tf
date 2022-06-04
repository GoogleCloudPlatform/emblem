module "emblem_ops" {
  source                  = "../../modules/ops"
  project_id              = var.project_id
  region                  = var.region
  deploy_triggers         = var.deploy_triggers
  repo_owner              = var.repo_owner
  repo_name               = var.repo_name
}
