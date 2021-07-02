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

PARENT_PROJECT=$(gcloud config get-value project 2>/dev/null)
BILLING_ACCOUNT=$(gcloud beta billing projects describe ${PARENT_PROJECT} --format="value(billingAccountName)" | sed 's/billingAccounts\///')
EMBLEM_SUFFIX=$((RANDOM%9999999))

cat > terraform/terraform.tfvars <<EOF
suffix = "${EMBLEM_SUFFIX}"
billing_account = "${BILLING_ACCOUNT}"
EOF

# Set up the projects
cd terraform/
terraform init
terraform apply --auto-approve
 # Run it twice b/c of race condition in Artifact Registry creation
 # Probably there is a way to make it work better in the tf but this works for now
terraform apply --auto-approve 
cd ..

# Run the setup Cloud Build to do initial build and deploy
gcloud builds submit --config=setup.cloudbuild.yaml \
--substitutions=_DIR=website,_SUFFIX=${EMBLEM_SUFFIX}

gcloud builds submit --config=setup.cloudbuild.yaml \
--substitutions=_DIR=content-api,_SUFFIX=${EMBLEM_SUFFIX}



## Connect Repos: https://console.cloud.google.com/cloud-build/triggers/connect?project=35351384869
## THEN RUN
# gcloud alpha builds triggers create github \
# --name=web-push-to-main \
# --repo-owner=GoogleCloudPlatform --repo-name=emblem \
# --branch-pattern="^main$" --build-config=ops/build.cloudbuild.yaml \
# --included-files="website/*" --substitutions="_DIR"="website" \
# --project="emblem-ops-${EMBLEM_SUFFIX}"

# gcloud alpha builds triggers create pubsub \
# --name=web-deploy-staging --topic="projects/emblem-ops-${EMBLEM_SUFFIX}/topics/gcr" \
# --repo=https://www.github.com/GoogleCloudPlatform/emblem \
# --branch=cicd --build-config=ops/deploy.cloudbuild.yaml \
# --substitutions=_IMAGE_NAME='$(body.message.data.tag)',\
# _REGION=us-central1,_REVISION='$(body.message.messageId)',\
# _SERVICE=website,_TARGET_PROJECT='emblem-stage-${EMBLEM_SUFFIX}' \
# --project="emblem-ops-${EMBLEM_SUFFIX}"


