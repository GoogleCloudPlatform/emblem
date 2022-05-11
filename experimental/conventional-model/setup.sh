set -eu

# Required Environment variables:
# OPS_PROJECT_ID
# STAGING_PROJECT_ID

## Ops Project (minus triggers) ##

OPS_ENVIRONMENT_DIR=terraform/environments/ops
export TF_VAR_project_id=${OPS_PROJECT_ID}
terraform -chdir=${OPS_ENVIRONMENT_DIR} init
terraform -chdir=${OPS_ENVIRONMENT_DIR} plan

## Staging Project ##

STAGING_ENVIRONMENT_DIR=terraform/environments/staging
export TF_VAR_project_id=${STAGING_PROJECT_ID}
export TF_VAR_ops_project_id=${OPS_PROJECT_ID}

terraform -chdir=${STAGING_ENVIRONMENT_DIR} init  
terraform -chdir=${STAGING_ENVIRONMENT_DIR} Plan

## Prod Project ##

PROD_ENVIRONMENT_DIR=terraform/environments/prod
export TF_VAR_project_id=${PROD_PROJECT_ID}
export TF_VAR_ops_project_id=${OPS_PROJECT_ID}

terraform -chdir=${PROD_ENVIRONMENT_DIR} init  
terraform -chdir=${PROD_ENVIRONMENT_DIR} Plan

# DEPLOY TRIGGERS TO OPS PROJECT

export TF_VAR_project_id=${OPS_PROJECT}
export TF_VAR_deploy_triggers="true"
terraform -chdir=${OPS_ENVIRONMENT_DIR} plan // Plan: 4 to add