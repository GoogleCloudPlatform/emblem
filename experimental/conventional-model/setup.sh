set -eu

# Required Environment variables:
# OPS_PROJECT_ID
# STAGING_PROJECT_ID
# REPO_NAME
# REPO_OWNER

## Ops Project (minus triggers) ##

OPS_ENVIRONMENT_DIR=terraform/environments/ops
export TF_VAR_project_id=${OPS_PROJECT_ID}
terraform -chdir=${OPS_ENVIRONMENT_DIR} init
terraform -chdir=${OPS_ENVIRONMENT_DIR} apply

## Staging Project ##

STAGING_ENVIRONMENT_DIR=terraform/environments/staging
export TF_VAR_project_id=${STAGING_PROJECT_ID}
export TF_VAR_ops_project_id=${OPS_PROJECT_ID}

terraform -chdir=${STAGING_ENVIRONMENT_DIR} init  
terraform -chdir=${STAGING_ENVIRONMENT_DIR} apply

## Prod Project ##

PROD_ENVIRONMENT_DIR=terraform/environments/prod
export TF_VAR_project_id=${PROD_PROJECT_ID}
export TF_VAR_ops_project_id=${OPS_PROJECT_ID}

terraform -chdir=${PROD_ENVIRONMENT_DIR} init  
terraform -chdir=${PROD_ENVIRONMENT_DIR} apply

# ## Build Containers ##

# export REGION="us-central1"
# SHORT_SHA="setup"
# E2E_RUNNER_TAG="latest"

# gcloud builds submit --config=ops/api-build.cloudbuild.yaml \
# --project="$OPS_PROJECT" --substitutions=_REGION="$REGION",SHORT_SHA="$SHORT_SHA"

# gcloud builds submit --config=ops/web-build.cloudbuild.yaml \
# --project="$OPS_PROJECT" --substitutions=_REGION="$REGION",SHORT_SHA="$SHORT_SHA"

# gcloud builds submit --config=ops/e2e-runner-build.cloudbuild.yaml \
# --project="$OPS_PROJECT" --substitutions=_REGION="$REGION",_IMAGE_TAG="$E2E_RUNNER_TAG"




# DEPLOY TRIGGERS TO OPS PROJECT

export TF_VAR_project_id=${OPS_PROJECT_ID}
export TF_VAR_deploy_triggers="true"
export TF_VAR_repo_name=${REPO_NAME}
export TF_VAR_repo_owner=${REPO_OWNER}
terraform -chdir=${OPS_ENVIRONMENT_DIR} apply
