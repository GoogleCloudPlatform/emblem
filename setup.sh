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

# Run ./setup.sh from a project with a billing account enabled
# This will require 3 projects, for ops, staging, and prod
# To auto-create the projects, run new_project_setup.sh

# Check env variables
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

cat > terraform/terraform.tfvars <<EOF
google_prod_project_id = "${PROD_PROJECT}"
google_stage_project_id = "${STAGE_PROJECT}"
google_ops_project_id = "${OPS_PROJECT}"
EOF

######################
# Terraform Projects #
######################

cd terraform/
terraform init
terraform apply --auto-approve
cd ..

###################
# Deploy Services #
###################

# Build content API service
# Note: we specify empty values to pass Cloud Build validation
gcloud builds submit --config=setup.cloudbuild.yaml \
--substitutions=_DIR=content-api,\
_STAGING_API_URL="",\
_PROD_API_URL="",\
_STAGING_SESSION_BUCKET="",\
_PROD_SESSION_BUCKET="",\
_STAGING_PROJECT="$STAGE_PROJECT",\
_PROD_PROJECT="$PROD_PROJECT" \
--project="$OPS_PROJECT"

# Get API URLs
# (These are NOT known before the API service is built!)
STAGE_API_URL=$(gcloud run services list --project ${STAGE_PROJECT} --format "value(URL)")
PROD_API_URL=$(gcloud run services list --project ${PROD_PROJECT} --format "value(URL)")

# Build website service
gcloud builds submit --config=setup.cloudbuild.yaml \
--substitutions=_DIR=website,\
_STAGING_API_URL="$STAGE_API_URL",\
_PROD_API_URL="$PROD_API_URL",\
_STAGING_SESSION_BUCKET="${SESSION_BUCKET_ID}-stage",\
_PROD_SESSION_BUCKET="${SESSION_BUCKET_ID}-prod",\
_STAGING_PROJECT="$STAGE_PROJECT",\
_PROD_PROJECT="$PROD_PROJECT" \
--project="$OPS_PROJECT"

################
# Set up CI/CD #
################

REPO_CONNECT_URL="https://console.cloud.google.com/cloud-build/triggers/connect?\
project=${OPS_PROJECT}"
echo "Connect your repos: ${REPO_CONNECT_URL}"
python3 -m webbrowser ${REPO_CONNECT_URL}

read -p "Once your repo is connected, please continue by typing any key."

continue=1
while [[ ${continue} -gt 0 ]]
do

read -p "Please input the repo-owner [GoogleCloudPlatform]: " repo_owner
repo_owner=${name:-GoogleCloudPlatform}
read -p "Please input the repo name [emblem]: " repo_name
repo_name=${name:-emblem}

read -p "Is this the correct repo: ${repo_owner}/${repo_name}? (y/n) " yesno

if [[ ${yesno} == "y" ]]
then continue=0
fi

done

###################
# Create Triggers #
###################

gcloud alpha builds triggers create github \
--name=web-push-to-main \
--repo-owner=${repo_owner} --repo-name=${repo_name} \
--branch-pattern="^main$" --build-config=ops/build.cloudbuild.yaml \
--included-files="website/*" --substitutions=_DIR="website",\
_STAGING_PROJECT="$STAGE_PROJECT",_PROD_PROJECT="$PROD_PROJECT" \
--project="${OPS_PROJECT}"

gcloud alpha builds triggers create pubsub \
--name=web-deploy-staging --topic="projects/${OPS_PROJECT}/topics/gcr" \
--repo=https://www.github.com/${repo_owner}/${repo_name} \
--branch=main --build-config=ops/deploy.cloudbuild.yaml \
--substitutions=_IMAGE_NAME='$(body.message.data.tag)',\
_REGION=us-central1,_REVISION='$(body.message.messageId)',\
_SERVICE=website,_TARGET_PROJECT="$STAGE_PROJECT",\
_STAGING_PROJECT="$STAGE_PROJECT",_PROD_PROJECT="$PROD_PROJECT" \
--project="${OPS_PROJECT}"


