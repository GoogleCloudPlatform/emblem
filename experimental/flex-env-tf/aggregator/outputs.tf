output "ops_project_number" {
    value = data.terraform_remote_state.ops.outputs.ops_project_number
}

output "stage_project_number" {
    value = data.terraform_remote_state.stage.outputs.app.project_number
}
