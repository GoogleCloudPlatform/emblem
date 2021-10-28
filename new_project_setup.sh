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
# This will create 3 projects, for ops, staging, and prod

SUFFIX=$(openssl rand -hex 8)
REGION="us-central"

# Check env variables
if [[ -z "${EMBLEM_ORGANIZATION}" ]]; then
    echo "Please set the $(tput bold)EMBLEM_ORGANIZATION$(tput sgr0) variable"
    exit 1
elif [[ -z "${EMBLEM_BILLING_ACCOUNT}" ]]; then
    echo "Please set the $(tput bold)EMBLEM_BILLING_ACCOUNT$(tput sgr0) variable"
    exit 1
fi

# Clear Terraform state
rm terraform/*.tfstat*

# Generate project IDs
export PROD_PROJECT="emblem-prod-$SUFFIX"
export STAGE_PROJECT="emblem-stage-$SUFFIX"
export OPS_PROJECT="emblem-ops-$SUFFIX"

# TEMPORARY: echo project deletion commands
echo "------------------------------------------"
echo "gcloud projects delete $PROD_PROJECT -q | \\"
echo "gcloud projects delete $STAGE_PROJECT -q | \\"
echo "gcloud projects delete $OPS_PROJECT -q"
echo "------------------------------------------"

# Create new gcloud projects
echo 'y' | gcloud projects create $PROD_PROJECT --organization $EMBLEM_ORGANIZATION | \
echo 'y' | gcloud projects create $STAGE_PROJECT --organization $EMBLEM_ORGANIZATION | \
echo 'y' | gcloud projects create $OPS_PROJECT --organization $EMBLEM_ORGANIZATION

# Link billing accounts
gcloud alpha billing projects link $PROD_PROJECT --billing-account $EMBLEM_BILLING_ACCOUNT
gcloud alpha billing projects link $STAGE_PROJECT --billing-account $EMBLEM_BILLING_ACCOUNT
gcloud alpha billing projects link $OPS_PROJECT --billing-account $EMBLEM_BILLING_ACCOUNT

# Run setup script
sh setup.sh
