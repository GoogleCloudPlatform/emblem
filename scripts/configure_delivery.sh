#!/usr/bin/env bash
# Copyright 2022 Google LLC
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

# Configure Continuous Delivery for your Emblem instance.

# Variable list
#   PROD_PROJECT            GCP Project ID of the production project
#   STAGE_PROJECT           GCP Project ID of the staging project
#   OPS_PROJECT             GCP Project ID of the operations project
#   REPO_OWNER              GitHub user/organization name
#   REPO_NAME               GitHub repo name

set -e

echo
echo "$(tput bold)Setting up Cloud Build triggers...$(tput sgr0)"
echo

# Check input env variables
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

REPO_CONNECT_URL="https://console.cloud.google.com/cloud-build/triggers/connect?project=${OPS_PROJECT}"
echo "Connect your repos: ${REPO_CONNECT_URL}"
read -rp "Once your forked emblem repo is connected, please continue by typing any key."

if [[ -z "${REPO_NAME}" || -z "${REPO_NAME}" ]]
then
    continue=1
else
    continue=0
fi

while [[ ${continue} -gt 0 ]]; do
    read -rp "Please input the GitHub repository owner: " REPO_OWNER
    read -rp "Please input the GitHub repository name: " REPO_NAME
    read -rp "Integrate Cloud Build with the repository $(tput bold)https://github.com/${REPO_OWNER}/${REPO_NAME}$(tput sgr0)? (y/n) " yesno

    if [[ ${yesno} == "y" ]]; then
        continue=0
    fi
done

# Ops Project
OPS_ENVIRONMENT_DIR=terraform/environments/ops
cat > "${OPS_ENVIRONMENT_DIR}/terraform.tfvars" <<EOF
project_id = "${OPS_PROJECT}"
setup_cd_system="true"
repo_owner="${REPO_OWNER}"
repo_name="${REPO_NAME}"
EOF

gcloud builds submit ./terraform --project="$OPS_PROJECT" --config=./ops/terraform.cloudbuild.yaml \
--substitutions=_ENV="ops",_STATE_GCS_BUCKET_NAME=$STATE_GCS_BUCKET_NAME,_TF_SERVICE_ACCT=$TERRAFORM_SERVICE_ACCOUNT

# Staging Project
STAGE_ENVIRONMENT_DIR=terraform/environments/staging
cat > "${STAGE_ENVIRONMENT_DIR}/terraform.tfvars" <<EOF
project_id = "${STAGE_PROJECT}"
ops_project_id = "${OPS_PROJECT}"
setup_cd_system="true"
repo_owner="${REPO_OWNER}"
repo_name="${REPO_NAME}"
EOF

gcloud builds submit ./terraform --project="$OPS_PROJECT" --config=./ops/terraform.cloudbuild.yaml \
    --substitutions=_ENV="staging",_STATE_GCS_BUCKET_NAME=$STATE_GCS_BUCKET_NAME,_TF_SERVICE_ACCT=$TERRAFORM_SERVICE_ACCOUNT

# Prod Project
# Only deploy to separate project for multi-project setups
if [ "${PROD_PROJECT}" != "${STAGE_PROJECT}" ]; then 
    PROD_ENVIRONMENT_DIR=terraform/environments/prod
    cat > "${PROD_ENVIRONMENT_DIR}/terraform.tfvars" <<EOF
project_id = "${PROD_PROJECT}"
ops_project_id = "${OPS_PROJECT}"
setup_cd_system="true"
repo_owner="${REPO_OWNER}"
repo_name="${REPO_NAME}"
EOF
    gcloud builds submit ./terraform --project="$OPS_PROJECT" --config=./ops/terraform.cloudbuild.yaml \
    --substitutions=_ENV="prod",_STATE_GCS_BUCKET_NAME=$STATE_GCS_BUCKET_NAME,_TF_SERVICE_ACCT=$TERRAFORM_SERVICE_ACCOUNT
fi
