module "emblem_ops" {
  source     = "../../modules/ops"
  project_id = var.project_id
  region     = var.region
  cd_system  = var.cd_system
  repo_owner = var.repo_owner
  repo_name  = var.repo_name
}
