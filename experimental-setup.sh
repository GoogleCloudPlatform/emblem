#!/bin/bash
# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -eu

# Variable list
#   PROD_PROJECT_ID         GCP Project ID of the production project
#   STAGING_PROJECT_ID           GCP Project ID of the staging project
#   OPS_PROJECT_ID             GCP Project ID of the operations project
#   SKIP_TRIGGERS           If set, don't set up build triggers
#   SKIP_AUTH               If set, do not prompt to set up auth

## Ops Project (minus triggers) ##

OPS_ENVIRONMENT_DIR=terraform/environments/ops
export TF_VAR_project_id=${OPS_PROJECT_ID}
export TF_VAR_environment_project_ids="{\"prod\" = \"${PROD_PROJECT_ID}\", \"staging\" = \"${STAGING_PROJECT_ID}\"}"
terraform -chdir=${OPS_ENVIRONMENT_DIR} init
terraform -chdir=${OPS_ENVIRONMENT_DIR} apply --auto-approve

## Staging Project ##

STAGING_ENVIRONMENT_DIR=terraform/environments/staging
export TF_VAR_project_id=${STAGING_PROJECT_ID}
export TF_VAR_ops_project_id=${OPS_PROJECT_ID}

terraform -chdir=${STAGING_ENVIRONMENT_DIR} init
terraform -chdir=${STAGING_ENVIRONMENT_DIR} apply --auto-approve

## Prod Project ##

PROD_ENVIRONMENT_DIR=terraform/environments/prod
export TF_VAR_project_id=${PROD_PROJECT_ID}
export TF_VAR_ops_project_id=${OPS_PROJECT_ID}

terraform -chdir=${PROD_ENVIRONMENT_DIR} init
terraform -chdir=${PROD_ENVIRONMENT_DIR} apply --auto-approve

## Build Containers ##

export REGION="us-central1"
SHORT_SHA="setup"
E2E_RUNNER_TAG="latest"

gcloud builds submit --config=ops/api-build.cloudbuild.yaml \
    --project="$OPS_PROJECT_ID" --substitutions=_REGION="$REGION",SHORT_SHA="$SHORT_SHA"

gcloud builds submit --config=ops/web-build.cloudbuild.yaml \
    --project="$OPS_PROJECT_ID" --substitutions=_REGION="$REGION",SHORT_SHA="$SHORT_SHA"

gcloud builds submit --config=ops/e2e-runner-build.cloudbuild.yaml \
    --project="$OPS_PROJECT_ID" --substitutions=_REGION="$REGION",_IMAGE_TAG="$E2E_RUNNER_TAG"

## Prod Services ##

gcloud run deploy --allow-unauthenticated \
    --image "${REGION}-docker.pkg.dev/${OPS_PROJECT_ID}/content-api/content-api:${SHORT_SHA}" \
    --project "$PROD_PROJECT_ID" --service-account "api-manager@${PROD_PROJECT_ID}.iam.gserviceaccount.com" \
    --region "${REGION}" content-api

PROD_API_URL=$(gcloud run services describe content-api --project ${PROD_PROJECT_ID} --region ${REGION} --format "value(status.url)")
WEBSITE_VARS="EMBLEM_SESSION_BUCKET=${PROD_PROJECT_ID}-sessions"
WEBSITE_VARS="${WEBSITE_VARS},EMBLEM_API_URL=${PROD_API_URL}"

gcloud run deploy --allow-unauthenticated \
    --image "${REGION}-docker.pkg.dev/${OPS_PROJECT_ID}/website/website:${SHORT_SHA}" \
    --project "$PROD_PROJECT_ID" --service-account "website-manager@${PROD_PROJECT_ID}.iam.gserviceaccount.com" \
    --set-env-vars "$WEBSITE_VARS" --region "${REGION}" --tag "latest" \
    website

## Staging Services ##

gcloud run deploy --allow-unauthenticated \
    --image "${REGION}-docker.pkg.dev/${OPS_PROJECT_ID}/content-api/content-api:${SHORT_SHA}" \
    --project "$STAGING_PROJECT_ID" --service-account "api-manager@${STAGING_PROJECT_ID}.iam.gserviceaccount.com" \
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

### Set legacy env variables
export STAGE_PROJECT=$STAGING_PROJECT_ID
export OPS_PROJECT=$OPS_PROJECT_ID
export PROD_PROJECT=$PROD_PROJECT_ID

if [[ -z "$SKIP_TRIGGERS" ]]; then
    REPO_CONNECT_URL="https://console.cloud.google.com/cloud-build/triggers/connect?project=${OPS_PROJECT_ID}"
    echo "Connect your repos: ${REPO_CONNECT_URL}"
    read -p "Once your repo is connected, please continue by typing any key."
    continue=1
    while [[ ${continue} -gt 0 ]]; do

        read -p "Please input the repo owner [GoogleCloudPlatform]: " REPO_OWNER
        repo_owner=${repo_owner:-GoogleCloudPlatform}
        read -p "Please input the repo name [emblem]: " REPO_NAME
        repo_name=${repo_name:-emblem}

        read -p "Is this the correct repo: ${REPO_OWNER}/${REPO_NAME}? (y/n) " yesno

        if [[ ${yesno} == "y" ]]; then
            continue=0
        fi

    done

    export TF_VAR_project_id=${OPS_PROJECT_ID}
    export TF_VAR_deploy_triggers="true"
    export TF_VAR_repo_name=${REPO_NAME}
    export TF_VAR_repo_owner=${REPO_OWNER}
    terraform -chdir=${OPS_ENVIRONMENT_DIR} apply --auto-approve
    
    # Call via shell until Terraform integration
    export GITHUB_URL=https://github.com/$REPO_OWNER/$REPO_NAME
    sh ./scripts/pubsub_triggers.sh
fi

## Set up auth ##

if [[ -z "$SKIP_AUTH" ]]; then
    echo ""
    read -p "Would you like to configure $(tput bold)$(tput setaf 3)end-user authentication?$(tput sgr0) (y/n) " auth_yesno

    if [[ ${auth_yesno} == "y" ]]; then
        sh ./scripts/configure_auth.sh
    else
        echo "Skipping end-user authentication configuration. You can configure it later by running:"
        echo ""
        echo "  export $(tput bold)PROD_PROJECT$(tput sgr0)=$(tput setaf 6)${PROD_PROJECT_ID}$(tput sgr0)"
        echo "  export $(tput bold)STAGING_PROJECT$(tput sgr0)=$(tput setaf 6)${STAGING_PROJECT_ID}$(tput sgr0)"
        echo "  export $(tput bold)OPS_PROJECT$(tput sgr0)=$(tput setaf 6)${OPS_PROJECT_ID}$(tput sgr0)"
        echo "  $(tput setaf 6)sh scripts/configure_auth.sh$(tput sgr0)"
        echo ""
    fi
fi