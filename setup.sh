#!/usr/bin/env bash
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

# Should this script error, print out the line that was responsible
_error_report() {
  echo >&2 "Exited [$?] at line $(caller):"
  cat -n $0 | tail -n+$(($1 - 3)) | head -n7 | sed "4s/^\s*/>>> /"
}
trap '_error_report $LINENO' ERR


# Variable list
#   PROD_PROJECT            GCP Project ID of the production project
#   STAGE_PROJECT           GCP Project ID of the staging project
#   OPS_PROJECT             GCP Project ID of the operations project
#   SKIP_TERRAFORM          If set, don't set up infrastructure
#   SKIP_TRIGGERS           If set, don't set up build triggers
#   SKIP_AUTH               If set, do not prompt to set up auth
#   SKIP_BUILD              If set, do not build container images
#   SKIP_DEPLOY             If set, do not deploy services
#   USE_DEFAULT_ACCOUNT     If set, do not prompt for a GCP Account Name during database seeding
#   REPO_OWNER              GitHub user/organization name (default: GoogleCloudPlatform)
#   REPO_NAME               GitHub repo name (default: emblem)

# Default to empty, avoiding unbound variable errors.
SKIP_TERRAFORM=${SKIP_TERRAFORM:-}
SKIP_TRIGGERS=${SKIP_TRIGGERS:-1} # TEMPORARY: Suppress triggers during iterative fix.
SKIP_AUTH=${SKIP_AUTH:-}
SKIP_BUILD=${SKIP_BUILD:-}
SKIP_DEPLOY=${SKIP_DEPLOY:-}

# Check env variables are not empty strings
if [[ -z "${PROD_PROJECT}" ]]; then
    echo "Please set the $(tput bold)PROD_PROJECT$(tput sgr0) variable"
    exit 1
elif [[ -z "${STAGE_PROJECT}" ]]; then
    echo "Please set the $(tput bold)STAGE_PROJECT$(tput sgr0) variable"
    exit 1
elif [[ -z "${OPS_PROJECT}" ]]; then
    echo "Please set the $(tput bold)OPS_PROJECT$(tput sgr0) variable"
    exit 1
fi

## Initialize Variables ##
export REGION="us-central1"

# Force SKIP_TRIGGERS until fully integrated into Terraform ops module
export SKIP_TRIGGERS="true"

echo "Setting up a new instance of Emblem. There may be a few prompts to guide the process."

########################
# Infrastructure Setup #
########################

if [[ -z "$SKIP_TERRAFORM" ]]; then

    ## Cloud Build Trigger Setup #
    if [[ -z "$SKIP_TRIGGERS" ]]; then
        echo
        echo "$(tput bold)Setting up Cloud Build triggers...$(tput sgr0)"
        echo

        REPO_CONNECT_URL="https://console.cloud.google.com/cloud-build/triggers/connect?project=${OPS_PROJECT}"
        echo "Connect your repos: ${REPO_CONNECT_URL}"
        read -rp "Once your repo is connected, please continue by typing any key."
        continue=1
        while [[ ${continue} -gt 0 ]]; do
            read -rp "Please input the repo owner [GoogleCloudPlatform]: " REPO_OWNER
            repo_owner=${repo_owner:-GoogleCloudPlatform}
            read -rp "Please input the repo name [emblem]: " REPO_NAME
            repo_name=${repo_name:-emblem}

            read -rp "Is this the correct repo: ${REPO_OWNER}/${REPO_NAME}? (y/n) " yesno

            if [[ ${yesno} == "y" ]]; then
                continue=0
            fi
        done

        # Configure terraform to setup the CD system.
        export TF_VAR_setup_cd_system="true"
        export TF_VAR_repo_owner="${repo_owner}"
        export TF_VAR_repo_name="${repo_name}"
    fi # skip triggers

    ## Terraform ##

    echo
    echo "$(tput bold)Setting up your Cloud resources with Terraform...$(tput sgr0)"
    echo

    # Ops Project
    OPS_ENVIRONMENT_DIR=terraform/environments/ops
    export TF_VAR_project_id=${OPS_PROJECT}
    export TF_VAR_repo_owner=${OPS_PROJECT}
    export TF_VAR_repo_name=${OPS_PROJECT}
    terraform -chdir=${OPS_ENVIRONMENT_DIR} init
    terraform -chdir=${OPS_ENVIRONMENT_DIR} apply --auto-approve

    # Staging Project
    STAGE_ENVIRONMENT_DIR=terraform/environments/staging
    export TF_VAR_project_id=${STAGE_PROJECT}
    export TF_VAR_ops_project_id=${OPS_PROJECT}
    terraform -chdir=${STAGE_ENVIRONMENT_DIR} init
    terraform -chdir=${STAGE_ENVIRONMENT_DIR} apply --auto-approve

    # Prod Project
    # Only deploy to separate project for multi-project setups
    if [ "${PROD_PROJECT}" != "${STAGE_PROJECT}" ]; then 
        PROD_ENVIRONMENT_DIR=terraform/environments/prod
        export TF_VAR_project_id=${PROD_PROJECT}
        export TF_VAR_ops_project_id=${OPS_PROJECT}
        terraform -chdir=${PROD_ENVIRONMENT_DIR} init
        terraform -chdir=${PROD_ENVIRONMENT_DIR} apply --auto-approve
    fi

fi # skip terraform

########################
# Seed Default Content #
########################

echo
echo "$(tput bold)Seeding default content...$(tput sgr0)"
echo

pushd content-api/data
account=$(gcloud config get-value account 2> /dev/null)
if [[ -z "$USE_DEFAULT_ACCOUNT" ]]; then
    read -rp "Please input the repo owner [${account}]: " approver
fi
approver="${approver:-$account}"

GOOGLE_CLOUD_PROJECT="${STAGE_PROJECT}" python3 seed_test_approver.py "${approver}"
GOOGLE_CLOUD_PROJECT="${STAGE_PROJECT}" python3 seed_database.py
if [ "${PROD_PROJECT}" != "${STAGE_PROJECT}" ]; then
    GOOGLE_CLOUD_PROJECT="${PROD_PROJECT}" python3 seed_test_approver.py "${approver}"
    GOOGLE_CLOUD_PROJECT="${PROD_PROJECT}" python3 seed_database.py
fi
popd

####################
# Build Containers #
####################

SHORT_SHA="setup"
E2E_RUNNER_TAG="latest"

if [[ -z "$SKIP_BUILD" ]]; then

echo
echo "$(tput bold)Building container images for testing and application hosting...$(tput sgr0)"
echo

gcloud builds submit --config=ops/api-build.cloudbuild.yaml \
    --project="$OPS_PROJECT" --substitutions=_REGION="$REGION",SHORT_SHA="$SHORT_SHA"

gcloud builds submit --config=ops/web-build.cloudbuild.yaml \
    --project="$OPS_PROJECT" --substitutions=_REGION="$REGION",SHORT_SHA="$SHORT_SHA"

gcloud builds submit --config=ops/e2e-runner-build.cloudbuild.yaml \
    --project="$OPS_PROJECT" --substitutions=_REGION="$REGION",_IMAGE_TAG="$E2E_RUNNER_TAG"

fi # skip build


##################
# Deploy Services #
##################

if [[ -z "$SKIP_DEPLOY" ]]; then

echo
echo "$(tput bold)Deploying Cloud Run services...$(tput sgr0)"
echo

## Production Services ##

# Only deploy to separate project for multi-project setups
if [ "${PROD_PROJECT}" != "${STAGE_PROJECT}" ]; then 
gcloud run deploy content-api \
    --allow-unauthenticated \
    --image "${REGION}-docker.pkg.dev/${OPS_PROJECT}/content-api/content-api:${SHORT_SHA}" \
    --service-account "api-manager@${PROD_PROJECT}.iam.gserviceaccount.com" \
    --project "${PROD_PROJECT}" \
    --region "${REGION}"

PROD_API_URL=$(gcloud run services describe content-api --project "${PROD_PROJECT}" --region ${REGION} --format 'value(status.url)')
gcloud run deploy website \
    --allow-unauthenticated \
    --image "${REGION}-docker.pkg.dev/${OPS_PROJECT}/website/website:${SHORT_SHA}" \
    --service-account "website-manager@${PROD_PROJECT}.iam.gserviceaccount.com" \
    --update-env-vars "EMBLEM_SESSION_BUCKET=${PROD_PROJECT}-sessions" \
    --update-env-vars "EMBLEM_API_URL=${PROD_API_URL}" \
    --project "${PROD_PROJECT}" \
    --region "${REGION}" \
    --tag "latest"
fi

## Staging Services ##

gcloud run deploy content-api \
    --allow-unauthenticated \
    --image "${REGION}-docker.pkg.dev/${OPS_PROJECT}/content-api/content-api:${SHORT_SHA}" \
    --service-account "api-manager@${STAGE_PROJECT}.iam.gserviceaccount.com" \
    --project "${STAGE_PROJECT}" \
    --region "${REGION}" 

STAGING_API_URL=$(gcloud run services describe content-api --project "${STAGE_PROJECT}" --region ${REGION} --format 'value(status.url)')
gcloud run deploy website \
    --allow-unauthenticated \
    --image "${REGION}-docker.pkg.dev/${OPS_PROJECT}/website/website:${SHORT_SHA}" \
    --service-account "website-manager@${STAGE_PROJECT}.iam.gserviceaccount.com" \
    --update-env-vars "EMBLEM_SESSION_BUCKET=${STAGE_PROJECT}-sessions" \
    --update-env-vars "EMBLEM_API_URL=${STAGING_API_URL}" \
    --project "${STAGE_PROJECT}" \
    --region "${REGION}" \
    --tag "latest"

fi # skip deploy

#######################
# User Authentication #
#######################

if [[ -z "$SKIP_AUTH" ]]; then
    echo
    read -rp "Would you like to configure $(tput bold)$(tput setaf 3)end-user authentication?$(tput sgr0) (y/n) " auth_yesno

    if [[ ${auth_yesno} == "y" ]]; then
        sh ./scripts/configure_auth.sh
    else
        echo "Skipping end-user authentication configuration. You can configure it later by running:"
        echo
        echo "  export $(tput bold)PROD_PROJECT$(tput sgr0)=$(tput setaf 6)${PROD_PROJECT}$(tput sgr0)"
        echo "  export $(tput bold)STAGE_PROJECT$(tput sgr0)=$(tput setaf 6)${STAGE_PROJECT}$(tput sgr0)"
        echo "  export $(tput bold)OPS_PROJECT$(tput sgr0)=$(tput setaf 6)${OPS_PROJECT}$(tput sgr0)"
        echo "  $(tput setaf 6)sh scripts/configure_auth.sh$(tput sgr0)"
        echo
    fi
fi # skip authentication
