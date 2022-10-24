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

set -eu

# Should this script error, print out the line that was responsible
_error_report() {
  echo >&2 "Exited [$?] at line $(caller):"
  cat -n $0 | tail -n+$(($1 - 3)) | head -n7 | sed "4s/^\s*/>>> /"
}
trap '_error_report $LINENO' ERR


export REGION=${REGION:=us-central1}

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

# TF Resources
# App Terraform resources include dependencies on ops resources, so the ops environment should be destroyed last to avoid errors.  

STATE_GCS_BUCKET_NAME="$OPS_PROJECT-tf-states"

PROD_ENVIRONMENT_DIR=terraform/environments/prod
terraform -chdir=${PROD_ENVIRONMENT_DIR} destroy --auto-approve && rm ${PROD_ENVIRONMENT_DIR}/terraform.tfvars && rm -rf ${PROD_ENVIRONMENT_DIR}/.terraform

STAGE_ENVIRONMENT_DIR=terraform/environments/staging
terraform -chdir=${STAGE_ENVIRONMENT_DIR} destroy --auto-approve && rm ${STAGE_ENVIRONMENT_DIR}/terraform.tfvars && rm -rf ${STAGE_ENVIRONMENT_DIR}/.terraform

OPS_ENVIRONMENT_DIR=terraform/environments/ops
terraform -chdir=${OPS_ENVIRONMENT_DIR} destroy --auto-approve && rm ${OPS_ENVIRONMENT_DIR}/terraform.tfvars && rm -rf ${OPS_ENVIRONMENT_DIR}/.terraform

# Delete GCS state bucket
gsutil -m rm -r gs://${STATE_GCS_BUCKET_NAME}/* && gsutil rb gs://${STATE_GCS_BUCKET_NAME}

# Delete Run services
gcloud run services delete --project $STAGE_PROJECT --region $REGION website --quiet
gcloud run services delete --project $STAGE_PROJECT --region $REGION content-api --quiet

gcloud run services delete --project $PROD_PROJECT --region $REGION website --quiet
gcloud run services delete --project $PROD_PROJECT --region $REGION content-api --quiet

# Delete Firestore data
echo
echo "Delete Firestore test data via Google Cloud console: "
echo
echo "Prod: https://console.cloud.google.com/firestore/data/panel/?project=${PROD_PROJECT}"
echo "Stage: https://console.cloud.google.com/firestore/data/panel/?project=${STAGE_PROJECT}"
echo
