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
# This will create a single project.


pushd $(dirname "$0") > /dev/null


PARENT_PROJECT=$(gcloud config get-value project 2>/dev/null)
BILLING_ACCOUNT=$(gcloud beta billing projects describe ${PARENT_PROJECT} --format="value(billingAccountName)" | sed 's/billingAccounts\///')


function execute_terraform () {
    PROJECT_ID_DEFAULT="${USER}-emblem-${1}"

    read -p $"Please enter the $(tput setaf 1)$(tput bold)$1$(tput sgr0) project ID: [${PROJECT_ID_DEFAULT}]   " PROJECT_ID
    PROJECT_ID="${PROJECT_ID:-${PROJECT_ID_DEFAULT}}"

    PROJECT_NAME=$(gcloud projects describe ${PROJECT_ID} | grep name | cut -d' ' -f 2-)

    # Specify project ID for Terraform to use
    export TF_VAR_google_project_id="$PROJECT_NAME"

    #terraform init
    #terraform apply --auto-approve
}

###########################
# Terraform - ops project #
###########################
pushd terraform/ops > /dev/null
execute_terraform "ops"
popd > /dev/null

# Record project name
OPS_PROJECT="$PROJECT_NAME"


##################################
# Terraform - production project #
##################################
export TF_VAR_release_type="prod"

pushd terraform/deployment > /dev/null
execute_terraform "prod"
popd > /dev/null

# Record project name
PROD_PROJECT="$PROJECT_NAME"


###############################
# Terraform - staging project #
###############################
export TF_VAR_release_type="stage"

pushd terraform/deployment > /dev/null
execute_terraform "stage"
popd > /dev/null

# Record project name
STAGE_PROJECT="$PROJECT_NAME"


###################
# Deploy Services #
###################

# Make sure website has all dependencies
# (including a copy of the client-libs/ folder)
pushd website > /dev/null
pip install -r requirements.txt
popd > /dev/null

# Submit remote builds
gcloud builds submit --config=setup.cloudbuild.yaml \
--substitutions="_DIR=website,_STAGING_PROJECT=${STAGE_PROJECT},_PROD_PROJECT=${PROD_PROJECT}" \
--project="${OPS_PROJECT}"

gcloud builds submit --config=setup.cloudbuild.yaml \
--substitutions="_DIR=content-api,_STAGING_PROJECT=${STAGE_PROJECT},_PROD_PROJECT=${PROD_PROJECT}" \
--project="${OPS_PROJECT}"


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
--included-files="website/*" --substitutions="_DIR"="website" \
--project="${OPS_PROJECT}"

gcloud alpha builds triggers create pubsub \
--name=web-deploy-staging --topic="projects/${OPS_PROJECT}/topics/gcr" \
--repo=https://www.github.com/${repo_owner}/${repo_name} \
--branch=main --build-config=ops/deploy.cloudbuild.yaml \
--substitutions=_IMAGE_NAME='$(body.message.data.tag)',\
_REGION=us-central1,_REVISION='$(body.message.messageId)',\
_SERVICE=website,_TARGET_PROJECT='${STAGE_PROJECT}' \
--project="${OPS_PROJECT}"


