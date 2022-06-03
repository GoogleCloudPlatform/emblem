variable "environment_project_ids" {
  type = map(string)
  description = "Map containing environment names and project IDs"
}

resource "null_resource" "web_deploy" {
  for_each = var.environment_project_ids
}

resource "null_resource" "api_deploy" {
  for_each = var.environment_project_ids
}

resource "null_resource" "web_canary" {
  for_each = var.environment_project_ids
}

resource "null_resource" "api_canary" {
  for_each = var.environment_project_ids
}
