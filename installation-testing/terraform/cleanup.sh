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

REGION="${REGION:-us-central1}"

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

#########################################
#   This script deletes resources not   #
# deleted by `terraform apply -destroy` #
#########################################

echo "###################################################"
echo "# THIS IS A CLEANUP SCRIPT (errors are not fatal) #"
echo "###################################################"

# Pub/Sub topics
gcloud pubsub topics delete gcr \
    --project "$OPS_PROJECT" \
    || true
gcloud pubsub topics delete nightly-builds \
    --project "$OPS_PROJECT" \
    || true
gcloud pubsub topics delete "canary-${PROD_PROJECT}" \
    --project "$OPS_PROJECT" \
    || true
gcloud pubsub topics delete "deploy-${PROD_PROJECT}" \
    --project "$OPS_PROJECT" \
    || true

gcloud pubsub topics delete "canary-${STAGE_PROJECT}" \
    --project "$OPS_PROJECT" \
    || true
gcloud pubsub topics delete "deploy-${STAGE_PROJECT}" \
    --project "$OPS_PROJECT" \
    || true

# Artifact Registry repositories
gcloud artifacts repositories delete website \
    --project "$OPS_PROJECT" \
    --location "$REGION" \
    -q \
    || true
gcloud artifacts repositories delete content-api \
    --project "$OPS_PROJECT" \
    --location "$REGION" \
    -q \
    || true
gcloud artifacts repositories delete e2e-runner \
    --project "$OPS_PROJECT" \
    --location "$REGION" \
    -q \
    || true

# Service accounts
gcloud iam service-accounts delete \
    "website-test-user@${OPS_PROJECT}.iam.gserviceaccount.com" \
    --project "$OPS_PROJECT" \
    -q \
    || true
gcloud iam service-accounts delete \
    "website-test-approver@${OPS_PROJECT}.iam.gserviceaccount.com" \
    --project "$OPS_PROJECT" \
    -q \
    || true

gcloud iam service-accounts delete \
    "cloud-run-manager@${STAGE_PROJECT}.iam.gserviceaccount.com" \
    --project "$STAGE_PROJECT" \
    -q \
    || true
gcloud iam service-accounts delete \
    "website-manager@${STAGE_PROJECT}.iam.gserviceaccount.com" \
    --project "$STAGE_PROJECT" \
    -q \
    || true
gcloud iam service-accounts delete \
    "api-manager@${STAGE_PROJECT}.iam.gserviceaccount.com" \
    --project "$STAGE_PROJECT" \
    -q \
    || true

gcloud iam service-accounts delete \
    "cloud-run-manager@${PROD_PROJECT}.iam.gserviceaccount.com" \
    --project "$PROD_PROJECT" \
    -q \
    || true
gcloud iam service-accounts delete \
    "website-manager@${PROD_PROJECT}.iam.gserviceaccount.com" \
    --project "$PROD_PROJECT" \
    -q \
    || true
gcloud iam service-accounts delete \
    "api-manager@${PROD_PROJECT}.iam.gserviceaccount.com" \
    --project "$PROD_PROJECT" \
    -q \
    || true

# Secrets
# (QUESTION: this will brick auth; **should** we delete these?)
gcloud secrets delete client_id_secret \
    --project "$OPS_PROJECT" \
    -q \
    || true
gcloud secrets delete client_secret_secret \
    --project "$OPS_PROJECT" \
    -q \
    || true

# Cloud Scheduler jobs
gcloud scheduler jobs delete nightly-builds \
    --project "$OPS_PROJECT" \
    --location "$REGION" \
    -q \
    || true

# Remove existing Terraform state (Part 1)
pushd terraform/environments/ops
terraform init
terraform apply \
    -destroy --auto-approve \
    -var google_ops_project_id="${OPS_PROJECT}" \
    || true
popd

# Remove existing Terraform state (Part 2)
pushd terraform/environments/staging
cat > terraform.tfvars <<EOF
ops_project_id = "${OPS_PROJECT}"
project_id = "${STAGE_PROJECT}"
EOF

terraform init
terraform apply \
    -destroy --auto-approve \
    -var google_ops_project_id="${OPS_PROJECT}" \
    -var google_project_id="${STAGE_PROJECT}" \
    || true
popd

# Remove existing Terraform state (Part 3)
pushd terraform/environments/prod
cat > terraform.tfvars <<EOF
ops_project_id = "${OPS_PROJECT}"
project_id = "${PROD_PROJECT}"
EOF

terraform init
terraform apply \
    -destroy --auto-approve \
    -var google_ops_project_id="${OPS_PROJECT}" \
    -var google_project_id="${PROD_PROJECT}" \
    || true
popd

echo "###################################################"
echo "#                   End cleanup                   #"
echo "###################################################"
