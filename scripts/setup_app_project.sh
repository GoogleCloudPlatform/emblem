#!/bin/bash
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


# This script sets up Terraform resources
# for Emblem's prod and/or dev GCP projects
#
# It is typically run as part of the setup
# script located at `(repo root)/setup.sh`


# Variable list
#   IMPORT_IAM              If set, import existing IAM resources instead of creating new ones
#   APP_PROJECT (param)     GCP Project ID of the prod and/or dev project
#   OPS_PROJECT             GCP Project ID of the operations project


#############
# Variables #
#############

# Check env variables are not empty strings
if [[ -z "${APP_PROJECT}" ]]; then
    echo "Please pass in the $(tput bold)APP_PROJECT$(tput sgr0) variable"
    exit 1
elif [[ -z "${OPS_PROJECT}" ]]; then
    echo "Please set the $(tput bold)OPS_PROJECT$(tput sgr0) variable"
    exit 1
fi

# Computed variables
APP_PROJECT_NUMBER="$(gcloud projects describe $APP_PROJECT --format 'value(projectNumber)')"
OPS_PROJECT_NUMBER="$(gcloud projects describe $OPS_PROJECT --format 'value(projectNumber)')"

CBSA_SA="serviceAccount:${OPS_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

# Store variables in Terraform config
cat > terraform.tfvars <<EOF
google_ops_project_id = "${OPS_PROJECT}"
google_project_id = "${APP_PROJECT}"
EOF

###############################
# Terraform Init + GAE Import #
###############################

terraform init --backend-config "path=./prod.tfstate" -reconfigure

# Import App Engine if it already exists in the project. 
# App Engine cannot be deleted so running terraform in a project with 
# an already extant App Engine project raises an error on terraform apply.
# Importing the module resolves the error.  
#
# Note: If AppEngine is in a different region than Cloud Run or in the wrong mode 
# (Datastore vs Firestore), this could cause latency or query compatibility issues.
terraform import \
    module.application.google_app_engine_application.main \
    "${APP_PROJECT}" \
    || true


#########################
# Terraform IAM Imports #
#########################

# Import existing IAM resources, so we don't have to
# create them programmatically when running CI tests

if [[ -n "${IMPORT_IAM}" ]]; then
    terraform import \
        google_project_iam_member.cloudbuild_role_run_admin \
        "${APP_PROJECT} roles/run.admin ${CBSA_SA}"
    terraform import \
        google_project_iam_member.cloudbuild_role_service_account_user \
        "${APP_PROJECT} roles/iam.serviceAccountUser ${CBSA_SA}"
    terraform import \
        module.application.google_service_account.cloud_run_manager \
        "projects/${APP_PROJECT}/serviceAccounts/cloud-run-manager@${APP_PROJECT}.iam.gserviceaccount.com"
    terraform import \
        module.application.google_service_account.website_manager \
        "projects/${APP_PROJECT}/serviceAccounts/website-manager@${APP_PROJECT}.iam.gserviceaccount.com"
    terraform import \
        module.application.google_service_account.api_manager \
        "projects/${APP_PROJECT}/serviceAccounts/api-manager@${APP_PROJECT}.iam.gserviceaccount.com"
    terraform import \
        module.application.google_storage_bucket.sessions \
        "${APP_PROJECT}/${APP_PROJECT}-sessions"
    terraform import \
        module.application.google_storage_bucket_iam_member.sessions-iam \
        "${APP_PROJECT}-sessions roles/storage.objectAdmin serviceAccount:website-manager@${APP_PROJECT}.iam.gserviceaccount.com"
fi

###################
# Terraform Apply #
###################

terraform apply --auto-approve \
    -var google_ops_project_id="${OPS_PROJECT}"
terraform state rm module.application.google_app_engine_application.main || true
