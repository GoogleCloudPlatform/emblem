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

# Ops Project
OPS_ENVIRONMENT_DIR=terraform/environments/ops
cat > "${OPS_ENVIRONMENT_DIR}/terraform.tfvars" <<EOF
setup_cd_system="true"
repo_owner="${REPO_OWNER}"
repo_name="${REPO_NAME}"
EOF
terraform -chdir=${OPS_ENVIRONMENT_DIR} apply --auto-approve

# Staging Project
STAGE_ENVIRONMENT_DIR=terraform/environments/staging
cat > "${STAGE_ENVIRONMENT_DIR}/terraform.tfvars" <<EOF
setup_cd_system="true"
repo_owner="${REPO_OWNER}"
repo_name="${REPO_NAME}"
EOF
terraform -chdir=${STAGE_ENVIRONMENT_DIR} apply --auto-approve

# Prod Project
# Only deploy to separate project for multi-project setups
if [ "${PROD_PROJECT}" != "${STAGE_PROJECT}" ]; then 
    PROD_ENVIRONMENT_DIR=terraform/environments/prod
cat >> "${PROD_ENVIRONMENT_DIR}/terraform.tfvars" <<EOF
setup_cd_system="true"
repo_owner="${REPO_OWNER}"
repo_name="${REPO_NAME}"
EOF
    terraform -chdir=${PROD_ENVIRONMENT_DIR} apply --auto-approve
fi
