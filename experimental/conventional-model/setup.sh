set -eu

# DEPLOY OPS PROJECT (MINUS TRIGGERS)
# Required environemnt variables: 
# - OPS_PROJECT

OPS_ENVIRONMENT_DIR=terraform/environments/ops
export TF_VAR_project_id=${OPS_PROJECT}

terraform -chdir=${OPS_ENVIRONMENT_DIR} init
terraform -chdir=${OPS_ENVIRONMENT_DIR} plan // Plan: 14 to add


# DEPLOY TRIGGERS TO OPS PROJECT

export TF_VAR_project_id=${OPS_PROJECT}
export TF_VAR_deploy_triggers="true"
terraform -chdir=${OPS_ENVIRONMENT_DIR} plan // Plan: 4 to add