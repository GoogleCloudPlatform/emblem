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
# To auto-create the projects, run clean_project_setup.sh

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


######################
# Terraform Projects #
######################


## Ops Project ##
pushd terraform/ops
terraform init
terraform apply --auto-approve \
    -var google_ops_project_id="${OPS_PROJECT}" 
popd


## Staging Project ##
pushd terraform/app

# Set Staging Variables
cat > terraform.tfvars <<EOF
google_ops_project_id = "${OPS_PROJECT}"
google_project_id = "${STAGE_PROJECT}"
EOF

terraform init --backend-config "path=./stage.tfstate" -reconfigure 
# Import App Engine if it already exists in the project. 
# App Engine cannot be deleted so running terraform in a project with 
# an already extant App Engine project raises an error on terraform apply.
# Importing the module resolves the error.  
#
# Note: If AppEngine is in a different region than Cloud Run or in the wrong mode 
# (Datastore vs Firestore), this could cause latency or query compatibility issues.

terraform import module.application.google_app_engine_application.main "${STAGE_PROJECT}" || true
terraform apply --auto-approve 

# Firestore requires App Engine for automatic provisioning.
# App Engine is not compatible with terraform destroy.
# This allows terraform destroy to run without modifying App Engine.
# Remove this when App Engine support for terraform destroy is fixed or Firestore has a direct provisioning solution.
# https://github.com/GoogleCloudPlatform/emblem/issues/217
terraform state rm module.application.google_app_engine_application.main || true


## Prod Project ##

# Set Prod Variables
cat > terraform.tfvars <<EOF
google_ops_project_id = "${OPS_PROJECT}"
google_project_id = "${PROD_PROJECT}"
EOF

terraform init --backend-config "path=./prod.tfstate" -reconfigure
terraform import module.application.google_app_engine_application.main "${PROD_PROJECT}" || true
terraform apply --auto-approve 
terraform state rm module.application.google_app_engine_application.main || true
    
# Return to root directory
popd

###################
# Deploy Services #
###################

REGION="us-central1"
SHORT_SHA="setup"

# Submit builds
gcloud builds submit --config=ops/api-build.cloudbuild.yaml \
--project="$OPS_PROJECT" --substitutions=_REGION="$REGION",SHORT_SHA="$SHORT_SHA"

gcloud builds submit --config=ops/web-build.cloudbuild.yaml \
--project="$OPS_PROJECT" --substitutions=_REGION="$REGION",SHORT_SHA="$SHORT_SHA"

# Deploy built images (API)
gcloud run deploy --allow-unauthenticated \
--image "${REGION}-docker.pkg.dev/${OPS_PROJECT}/content-api/content-api:${SHORT_SHA}" \
--project "$PROD_PROJECT"  --service-account "api-manager@${PROD_PROJECT}.iam.gserviceaccount.com" \
content-api

gcloud run deploy --allow-unauthenticated \
--image "${REGION}-docker.pkg.dev/${OPS_PROJECT}/content-api/content-api:${SHORT_SHA}" \
--project "$STAGE_PROJECT"  --service-account "api-manager@${STAGE_PROJECT}.iam.gserviceaccount.com"  \
content-api

# Deploy built images (website prod)
API_URL=$(gcloud run services list --project ${PROD_PROJECT} --format "value(URL)")

WEBSITE_VARS="EMBLEM_SESSION_BUCKET=${PROD_PROJECT}-sessions"
WEBSITE_VARS="${WEBSITE_VARS},EMBLEM_API_URL=${API_URL}"

gcloud run deploy --allow-unauthenticated \
--image "${REGION}-docker.pkg.dev/${OPS_PROJECT}/website/website:${SHORT_SHA}" \
--project "$PROD_PROJECT" --service-account "website-manager@${PROD_PROJECT}.iam.gserviceaccount.com"  \
--set-env-vars "$WEBSITE_VARS" \
website

# Deploy built images (website staging)
API_URL=$(gcloud run services list --project ${PROD_PROJECT} --format "value(URL)")

WEBSITE_VARS="EMBLEM_SESSION_BUCKET=${STAGE_PROJECT}-sessions"
WEBSITE_VARS="${WEBSITE_VARS},EMBLEM_API_URL=${API_URL}"

gcloud run deploy --allow-unauthenticated \
--image "${REGION}-docker.pkg.dev/${OPS_PROJECT}/website/website:${SHORT_SHA}" \
--project "$STAGE_PROJECT" --service-account "website-manager@${STAGE_PROJECT}.iam.gserviceaccount.com" \
--set-env-vars "$WEBSITE_VARS" \
website

###############
# Set up auth #
###############
echo ""
read -p "Would you like to configure $(tput bold)$(tput setaf 3)end-user authentication?$(tput sgr0) (y/n) " auth_yesno

if [[ ${auth_yesno} == "y" ]]; then
    sh ./scripts/configure_auth.sh
else
    echo "Skipping end-user authentication configuration. You can configure it later by running:"
    echo ""
    echo "  export $(tput bold)PROD_PROJECT$(tput sgr0)=$(tput setaf 6)${PROD_PROJECT}$(tput sgr0)"
    echo "  export $(tput bold)STAGE_PROJECT$(tput sgr0)=$(tput setaf 6)${STAGE_PROJECT}$(tput sgr0)"
    echo "  export $(tput bold)OPS_PROJECT$(tput sgr0)=$(tput setaf 6)${OPS_PROJECT}$(tput sgr0)"
    echo "  $(tput setaf 6)sh scripts/configure_auth.sh$(tput sgr0)"
    echo ""
fi

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

read -p "Please input the repo owner [GoogleCloudPlatform]: " repo_owner
repo_owner=${repo_owner:-GoogleCloudPlatform}
read -p "Please input the repo name [emblem]: " repo_name
repo_name=${repo_name:-emblem}

read -p "Is this the correct repo: ${repo_owner}/${repo_name}? (y/n) " yesno

if [[ ${yesno} == "y" ]]
then continue=0
fi

done

###################
# Create Triggers #
###################

pushd terraform/ops/triggers
# Set Trigger Variables
cat > terraform.tfvars <<EOF
google_ops_project_id = "${OPS_PROJECT}"
repo_owner = "${repo_owner}"
repo_name = "${repo_name}"
EOF

terraform init
terraform apply --auto-approve

gcloud alpha builds triggers create pubsub \
--name=web-deploy-staging --topic="projects/${OPS_PROJECT}/topics/gcr" \
--repo=https://github.com/${repo_owner}/${repo_name} \
--branch=main --build-config=ops/deploy.cloudbuild.yaml \
--substitutions=_IMAGE_NAME='$(body.message.data.tag)',\
_REGION="$REGION",_REVISION='$(body.message.messageId)',\
_SERVICE=website,_TARGET_PROJECT="$STAGE_PROJECT",\
_STAGING_PROJECT="$STAGE_PROJECT",_PROD_PROJECT="$PROD_PROJECT" \
--project="${OPS_PROJECT}"


