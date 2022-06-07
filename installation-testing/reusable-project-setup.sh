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

set -eux

_error_report() {
  echo >&2 "Exited [$?] at line $(caller):"
  cat -n $0 | tail -n+$(($1 - 3)) | head -n7 | sed "4s/^\s*/>>> /"
}
trap '_error_report $LINENO' ERR


# Variable list
#   PROD_PROJECT            GCP Project ID of the production project
#   STAGE_PROJECT           GCP Project ID of the staging project
#   SKIP_TERRAFORM          If set, don't set up infrastructure

# Default to empty, avoiding unbound variable errors.
SKIP_TERRAFORM=${SKIP_TERRAFORM:-}

# Check env variables are not empty strings
if [[ -z "${PROD_PROJECT}" ]]; then
    echo "Please set the $(tput bold)PROD_PROJECT$(tput sgr0) variable"
    exit 1
elif [[ -z "${STAGE_PROJECT}" ]]; then
    echo "Please set the $(tput bold)STAGE_PROJECT$(tput sgr0) variable"
    exit 1
fi

## Initialize Variables ##
export REGION="us-central1"

if [[ -z "$SKIP_TERRAFORM" ]]; then

    ## Staging Project ##
    STAGE_ENVIRONMENT_DIR=terraform/environments/staging
    export TF_VAR_project_id=${STAGE_PROJECT}
    export TF_VAR_ops_project_id=${OPS_PROJECT}
    terraform -chdir=${STAGE_ENVIRONMENT_DIR} init
    terraform -chdir=${STAGE_ENVIRONMENT_DIR} import \
        module.emblem_staging.google_storage_bucket.sessions \
        "${STAGE_PROJECT}-sessions" || true

    ## Prod Project ##
    # Only deploy to separate project for multi-project setups
    if [ "${PROD_PROJECT}" != "${STAGE_PROJECT}" ]; then 
        PROD_ENVIRONMENT_DIR=terraform/environments/prod
        export TF_VAR_project_id=${PROD_PROJECT}
        export TF_VAR_ops_project_id=${OPS_PROJECT}
        terraform -chdir=${PROD_ENVIRONMENT_DIR} init
        terraform -chdir=${PROD_ENVIRONMENT_DIR} import \
            module.emblem_prod.google_storage_bucket.sessions \
            "${PROD_PROJECT}-sessions" || true
    fi
fi
