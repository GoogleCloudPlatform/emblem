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
#   SKIP_TRIGGERS           If set, don't set up build triggers
#   SKIP_AUTH               If set, do not prompt to set up auth
#   SKIP_BUILD              If set, do not build container images
#   SKIP_DEPLOY             If set, do not deploy services
#   SKIP_SEEDING            If set, do not seed the database
#   USE_DEFAULT_ACCOUNT     If set, do not prompt for a GCP Account Name during database seeding
#   REGION                  Default region to deploy resources to. Defaults to 'us-central1'

# Default to empty or default values, avoiding unbound variable errors.
SKIP_TRIGGERS=${SKIP_TRIGGERS:-}
SKIP_AUTH=${SKIP_AUTH:=true}
SKIP_BUILD=${SKIP_BUILD:-}
SKIP_DEPLOY=${SKIP_DEPLOY:-}
SKIP_SEEDING=${SKIP_SEEDING:-}
USE_DEFAULT_ACCOUNT=${USE_DEFAULT_ACCOUNT:-}
export REGION=${REGION:=us-central1}

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

echo "Setting up a new instance of Emblem. There may be a few prompts to guide the process."

./scripts/bootstrap.sh

#####################
# Initial Ops Setup #
#####################

echo
echo "$(tput bold)Setting up your Cloud resources with Terraform...$(tput sgr0)"
echo
export TERRAFORM_SERVICE_ACCOUNT="emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com"
export STATE_GCS_BUCKET_NAME="$OPS_PROJECT-tf-states"

# Ops Project
OPS_ENVIRONMENT_DIR=terraform/environments/ops
cat > "${OPS_ENVIRONMENT_DIR}/terraform.tfvars" <<EOF
    project_id = "${OPS_PROJECT}"
EOF

gcloud builds submit ./terraform --project="$OPS_PROJECT" \
    --config=./ops/terraform.cloudbuild.yaml \
    --substitutions=_ENV="ops",_STATE_GCS_BUCKET_NAME=$STATE_GCS_BUCKET_NAME,_TF_SERVICE_ACCT=$TERRAFORM_SERVICE_ACCOUNT

####################
# Build Containers #
####################

SETUP_IMAGE_TAG="setup"
E2E_RUNNER_TAG="latest"

if [[ -z "$SKIP_BUILD" ]]; then

echo
echo "$(tput bold)Building container images for testing and application hosting...$(tput sgr0)"
echo

API_BUILD_ID=$(gcloud builds submit "content-api" --async \
    --config=ops/api-build.cloudbuild.yaml \
    --project="$OPS_PROJECT" --substitutions=_REGION="$REGION",_IMAGE_TAG="$SETUP_IMAGE_TAG",_CONTEXT="." --format='value(ID)')

WEB_BUILD_ID=$(gcloud builds submit \
    --config=ops/web-build.cloudbuild.yaml --async \
    --ignore-file=ops/web-build.gcloudignore \
    --project="$OPS_PROJECT" --substitutions=_REGION="$REGION",_IMAGE_TAG="$SETUP_IMAGE_TAG" --format='value(ID)')

E2E_BUILD_ID=$(gcloud builds submit "ops/e2e-runner" --async \
    --config=ops/e2e-runner-build.cloudbuild.yaml \
    --project="$OPS_PROJECT" --substitutions=_REGION="$REGION",_IMAGE_TAG="$E2E_RUNNER_TAG" --format='value(ID)')

fi # skip build

#####################
# Application Setup #
#####################

# Staging Project
STAGE_ENVIRONMENT_DIR=terraform/environments/staging
cat > "${STAGE_ENVIRONMENT_DIR}/terraform.tfvars" <<EOF
project_id = "${STAGE_PROJECT}"
ops_project_id = "${OPS_PROJECT}"
EOF
terraform -chdir=${STAGE_ENVIRONMENT_DIR} init -backend-config="bucket=${STATE_GCS_BUCKET_NAME}" -backend-config="prefix=stage"
terraform -chdir=${STAGE_ENVIRONMENT_DIR} apply --auto-approve

# Prod Project
# Only deploy to separate project for multi-project setups
if [ "${PROD_PROJECT}" != "${STAGE_PROJECT}" ]; then 
    PROD_ENVIRONMENT_DIR=terraform/environments/prod
cat > "${PROD_ENVIRONMENT_DIR}/terraform.tfvars" <<EOF
project_id = "${PROD_PROJECT}"
ops_project_id = "${OPS_PROJECT}"
EOF
    terraform -chdir=${PROD_ENVIRONMENT_DIR} init -backend-config="bucket=${STATE_GCS_BUCKET_NAME}" -backend-config="prefix=prod"
    terraform -chdir=${PROD_ENVIRONMENT_DIR} apply --auto-approve
fi



########################
# Seed Default Content #
########################
if [[ -z "$SKIP_SEEDING" ]]; then
    echo
    echo "$(tput bold)Seeding default content...$(tput sgr0)"
    echo

    account=$(gcloud config get-value account 2> /dev/null)
    if [[ -z "$USE_DEFAULT_ACCOUNT" ]]; then
        read -rp "Please input an email address for an approver. This email will be added to the Firestore database as an 'approver' and will be able to perform privileged API operations from the website frontend: [${account}]: " approver
    fi
    approver="${approver:-$account}"

    gcloud builds submit content-api/data  --project="$OPS_PROJECT" --async \
    --substitutions=_FIREBASE_PROJECT="${STAGE_PROJECT}",_APPROVER_EMAIL="${approver}" \
    --config=./content-api/data/cloudbuild.yaml

    if [ "${PROD_PROJECT}" != "${STAGE_PROJECT}" ]; then
        gcloud builds submit content-api/data  --project="$OPS_PROJECT" --async \
        --substitutions=_FIREBASE_PROJECT="${PROD_PROJECT}",_APPROVER_EMAIL="${approver}" \
        --config=./content-api/data/cloudbuild.yaml
    fi
fi # skip seeding

##################
# Deploy Services #
##################

# This function will wait for job status for the provided build job to update 
# from WORKING to FAILURE or SUCCESS. For failed build jobs, the failure info 
# will be returned along with the url to the build log. For successful build 
# jobs, the provided run command will be executed. For all other statuses,
# url to the build log is returned.

check_for_build_then_run () {
    local build_id="${1}"
    local run_command="${2}"
    # Wait for build to complete.
    if [ $(gcloud builds describe $build_id --project=$OPS_PROJECT  --format='value(status)') == "WORKING" ]; then
        log_url=$(gcloud builds describe $build_id --project=$OPS_PROJECT --format='value(logUrl)')
        echo "Build $build_id still working."
        echo "Logs are available at [ $log_url ]."
        while [ $(gcloud builds describe $build_id --project=$OPS_PROJECT  --format='value(status)') == "WORKING" ]
        do
          echo "Build $build_id still working..."
          sleep 10
        done
    fi
    # Return error and build log for failures. 
    if [ $(gcloud builds describe $build_id --project=$OPS_PROJECT --format='value(status)') == "FAILURE" ]; then
        build_describe=$(gcloud builds describe $build_id --project=$OPS_PROJECT --format='csv(failureInfo.detail,logUrl)[no-heading]')
        fail_info=$(echo $build_describe | awk -F',' '{gsub(/""/,"\"");print $1}')
        log_url=$(echo $build_describe | awk -F',' '{print $2}')
        echo "Build ${build_id} failed. See build log: $log_url"
        echo "ERROR: ${fail_info}"
        echo "Please re-run setup."
        exit 2
    # Deploy if build is successful.
    elif [ $(gcloud builds describe $build_id --project=$OPS_PROJECT --format='value(status)') == "SUCCESS" ]; then
        $run_command
    # Return build log for all other statuses.
    else
        log_url=$(gcloud builds describe $build_id --project=$OPS_PROJECT --format='value(logUrl)')
        echo "Build ${build_id} did not complete." 
        echo "See build log: $log_url"
        echo "Please re-run setup."
        exit 2
    fi;
}

if [[ -z "$SKIP_DEPLOY" ]]; then

    echo
    echo "$(tput bold)Deploying Cloud Run services...$(tput sgr0)"
    echo

    ## Staging Services ##
    check_for_build_then_run $API_BUILD_ID "gcloud run deploy content-api \
        --allow-unauthenticated \
        --image "${REGION}-docker.pkg.dev/${OPS_PROJECT}/content-api/content-api:${SETUP_IMAGE_TAG}" \
        --service-account "api-manager@${STAGE_PROJECT}.iam.gserviceaccount.com" \
        --project "${STAGE_PROJECT}" \
        --region "${REGION}""

    STAGING_API_URL=$(gcloud run services describe content-api --project "${STAGE_PROJECT}" --region ${REGION} --format 'value(status.url)')
    
    check_for_build_then_run $WEB_BUILD_ID "gcloud run deploy website \
        --allow-unauthenticated \
        --image "${REGION}-docker.pkg.dev/${OPS_PROJECT}/website/website:${SETUP_IMAGE_TAG}" \
        --service-account "website-manager@${STAGE_PROJECT}.iam.gserviceaccount.com" \
        --update-env-vars "EMBLEM_SESSION_BUCKET=${STAGE_PROJECT}-sessions" \
        --update-env-vars "EMBLEM_API_URL=${STAGING_API_URL}" \
        --project "${STAGE_PROJECT}" \
        --region "${REGION}" \
        --tag "latest""

    ## Production Services ##

    # Only deploy to separate project for multi-project setups
    if [ "${PROD_PROJECT}" != "${STAGE_PROJECT}" ]; then
        check_for_build_then_run $API_BUILD_ID "gcloud run deploy content-api \
            --allow-unauthenticated \
            --image "${REGION}-docker.pkg.dev/${OPS_PROJECT}/content-api/content-api:${SETUP_IMAGE_TAG}" \
            --service-account "api-manager@${PROD_PROJECT}.iam.gserviceaccount.com" \
            --project "${PROD_PROJECT}" \
            --region "${REGION}""

        PROD_API_URL=$(gcloud run services describe content-api --project "${PROD_PROJECT}" --region ${REGION} --format 'value(status.url)')
        
        check_for_build_then_run $WEB_BUILD_ID "gcloud run deploy website \
            --allow-unauthenticated \
            --image "${REGION}-docker.pkg.dev/${OPS_PROJECT}/website/website:${SETUP_IMAGE_TAG}" \
            --service-account "website-manager@${PROD_PROJECT}.iam.gserviceaccount.com" \
            --update-env-vars "EMBLEM_SESSION_BUCKET=${PROD_PROJECT}-sessions" \
            --update-env-vars "EMBLEM_API_URL=${PROD_API_URL}" \
            --project "${PROD_PROJECT}" \
            --region "${REGION}" \
            --tag "latest""
    fi

fi # skip deploy

###############
# Setup CI/CD #
###############

if [[ -z "$SKIP_TRIGGERS" ]]; then
    echo

    ./scripts/configure_delivery.sh
    
fi # skip triggers

echo
STAGING_WEBSITE_URL=$(gcloud run services describe website --project "${STAGE_PROJECT}" --region ${REGION} --format 'value(status.url)')
if [ "${PROD_PROJECT}" != "${STAGE_PROJECT}" ]; then
  PROD_WEBSITE_URL=$(gcloud run services describe website --project "${PROD_PROJECT}" --region ${REGION} --format 'value(status.url)')
  echo "💠 The staging environment is ready! Navigate your browser to ${STAGING_WEBSITE_URL}"
  echo "💠 The production environment is ready! Navigate your browser to ${PROD_WEBSITE_URL}"
else
  echo "💠 The application is ready! Navigate your browser to ${STAGING_WEBSITE_URL}"
fi

#######################
# User Authentication #
#######################

if [[ -z "$SKIP_AUTH" ]]; then
    echo
    read -rp "Would you like to configure $(tput bold)$(tput setaf 3)end-user authentication?$(tput sgr0) (y/n) " auth_yesno

    if [[ ${auth_yesno} == "y" ]]; then
        ./scripts/configure_auth.sh
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
