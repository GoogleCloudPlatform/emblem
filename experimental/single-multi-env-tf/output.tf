output "ops_project_number" {
  value = data.google_project.main.number
}

# Publish application module outputs.
# Ex., app.staging.project_number
# To customize the module output, see
# https://stackoverflow.com/a/64992041
output app {
  value = module.application
}
