output "ops_project_number" {
  value = data.google_project.ops_project.number
}

output "stage_project_number" {
  value = module.application_service["stage"].project_number
}

output "prod_project_number" {
  value = module.application_service["prod"].project_number
}
