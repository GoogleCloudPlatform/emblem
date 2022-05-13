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
terraform -chdir=${OPS_ENVIRONMENT_DIR} plan

# ## Staging Project ##

STAGING_ENVIRONMENT_DIR=terraform/environments/staging
export TF_VAR_project_id=${STAGING_PROJECT_ID}
export TF_VAR_ops_project_id=${OPS_PROJECT_ID}

terraform -chdir=${STAGING_ENVIRONMENT_DIR} init  
terraform -chdir=${STAGING_ENVIRONMENT_DIR} plan

## Prod Project ##

PROD_ENVIRONMENT_DIR=terraform/environments/prod
export TF_VAR_project_id=${PROD_PROJECT_ID}
export TF_VAR_ops_project_id=${OPS_PROJECT_ID}

terraform -chdir=${PROD_ENVIRONMENT_DIR} init  
terraform -chdir=${PROD_ENVIRONMENT_DIR} plan

## Build Containers ##

cd ../../
export REGION="us-central1"
SHORT_SHA="setup"
E2E_RUNNER_TAG="latest"

gcloud builds submit --config=ops/api-build.cloudbuild.yaml \
--project="$OPS_PROJECT_ID" --substitutions=_REGION="$REGION",SHORT_SHA="$SHORT_SHA"

gcloud builds submit --config=ops/web-build.cloudbuild.yaml \
--project="$OPS_PROJECT_ID" --substitutions=_REGION="$REGION",SHORT_SHA="$SHORT_SHA"

gcloud builds submit --config=ops/e2e-runner-build.cloudbuild.yaml \
--project="$OPS_PROJECT_ID" --substitutions=_REGION="$REGION",_IMAGE_TAG="$E2E_RUNNER_TAG"

cd -

## Prod Services ##

gcloud run deploy --allow-unauthenticated \
--image "${REGION}-docker.pkg.dev/${OPS_PROJECT_ID}/content-api/content-api:${SHORT_SHA}" \
--project "$PROD_PROJECT_ID"  --service-account "api-manager@${PROD_PROJECT_ID}.iam.gserviceaccount.com" \
--region "${REGION}" content-api

PROD_API_URL=$(gcloud run services describe content-api --project ${PROD_PROJECT_ID} --region ${REGION} --format "value(status.url)")
WEBSITE_VARS="EMBLEM_SESSION_BUCKET=${PROD_PROJECT_ID}-sessions"
WEBSITE_VARS="${WEBSITE_VARS},EMBLEM_API_URL=${PROD_API_URL}"

gcloud run deploy --allow-unauthenticated \
--image "${REGION}-docker.pkg.dev/${OPS_PROJECT_ID}/website/website:${SHORT_SHA}" \
--project "$PROD_PROJECT_ID" --service-account "website-manager@${PROD_PROJECT_ID}.iam.gserviceaccount.com"  \
--set-env-vars "$WEBSITE_VARS" --region "${REGION}" --tag "latest" \
website

## Staging Services ##

gcloud run deploy --allow-unauthenticated \
--image "${REGION}-docker.pkg.dev/${OPS_PROJECT_ID}/content-api/content-api:${SHORT_SHA}" \
--project "$STAGING_PROJECT_ID"  --service-account "api-manager@${STAGING_PROJECT_ID}.iam.gserviceaccount.com"  \
--region "${REGION}" content-api

STAGING_API_URL=$(gcloud run services describe content-api --project ${STAGING_PROJECT_ID} --region ${REGION} --format "value(status.url)")

WEBSITE_VARS="EMBLEM_SESSION_BUCKET=${STAGING_PROJECT_ID}-sessions"
WEBSITE_VARS="${WEBSITE_VARS},EMBLEM_API_URL=${STAGING_API_URL}"

gcloud run deploy --allow-unauthenticated \
--image "${REGION}-docker.pkg.dev/${OPS_PROJECT_ID}/website/website:${SHORT_SHA}" \
--project "$STAGING_PROJECT_ID" --service-account "website-manager@${STAGING_PROJECT_ID}.iam.gserviceaccount.com" \
--set-env-vars "$WEBSITE_VARS" --region "${REGION}" --tag "latest" \
website

## Deploy Triggers to Ops Project ##

export TF_VAR_project_id=${OPS_PROJECT_ID}
export TF_VAR_deploy_triggers="true"
export TF_VAR_repo_name=${REPO_NAME}
export TF_VAR_repo_owner=${REPO_OWNER}
terraform -chdir=${OPS_ENVIRONMENT_DIR} apply
