module "emblem_ops" {
  source          = "../../modules/ops"
  project_id      = var.project_id
  region          = var.region
  repo_owner      = var.repo_owner
  repo_name       = var.repo_name
  deploy_triggers = var.deploy_triggers
}
