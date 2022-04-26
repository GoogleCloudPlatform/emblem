output "ops_project_number" {
  value = data.google_project.main.number
}

# TODO: Official documentation indicates the name property is the ID. It is repository_id, the last part of the name.
# In our case, that means "content-api" and "website"
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository
output "artifact_registry" {
  value = {
    "api"         = google_artifact_registry_repository.api_docker.name
    "website"     = google_artifact_registry_repository.website_docker.name
    "cicd-runner" = google_artifact_registry_repository.cicd_runner_docker.name
  }
  description = "Application Artifact Registries"
}

output "secret_ids" {
  value = {
    "client_id"     = google_secret_manager_secret.oauth_client_id.secret_id
    "client_secret" = google_secret_manager_secret.oauth_client_secret.secret_id
  }
}
