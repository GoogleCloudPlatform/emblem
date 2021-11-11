#!/usr/bin/env bash
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

# This file creates fresh projects for testing Terraform and `setup.sh` configs
# This script creates 3 projects - one each for {ops, staging, prod}

cd $(dirname "$0") # Make future relative paths consistent

set -e

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
rm ../terraform/*.tfstat* || true

# Generate project IDs
export PROD_PROJECT="emblem-prod-$SUFFIX"
export STAGE_PROJECT="emblem-stage-$SUFFIX"
export OPS_PROJECT="emblem-ops-$SUFFIX"

# Generate session storage GCS bucket ID
export SESSION_BUCKET_ID="emblem-$SUFFIX"

# TEMPORARY: echo project deletion commands
echo "------------------------------------------"
echo "gcloud projects delete $PROD_PROJECT -q | \\"
echo "gcloud projects delete $STAGE_PROJECT -q | \\"
echo "gcloud projects delete $OPS_PROJECT -q"
echo "------------------------------------------"

# Create new gcloud projects
gcloud projects create $PROD_PROJECT --organization $EMBLEM_ORGANIZATION -q | \
gcloud projects create $STAGE_PROJECT --organization $EMBLEM_ORGANIZATION -q | \
gcloud projects create $OPS_PROJECT --organization $EMBLEM_ORGANIZATION -q

# Link billing accounts
gcloud alpha billing projects link $PROD_PROJECT --billing-account $EMBLEM_BILLING_ACCOUNT
gcloud alpha billing projects link $STAGE_PROJECT --billing-account $EMBLEM_BILLING_ACCOUNT
gcloud alpha billing projects link $OPS_PROJECT --billing-account $EMBLEM_BILLING_ACCOUNT

# Run setup script
pushd ..
exec ./setup.sh
popd
