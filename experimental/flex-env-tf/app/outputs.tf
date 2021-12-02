# Publish application module outputs.
# Ex., app.staging.project_number
# To customize the module output, see
# https://stackoverflow.com/a/64992041
output "project_number" {
  value = module.application.project_number
}

output "ops_project_number" {
  value = data.google_project.ops.number
}