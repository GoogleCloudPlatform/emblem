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

#########################################
# Hardcoded values used for setup_v2.sh #
#########################################

# Firebase API key used by the "emblem-dev" project
# (These API keys are NOT secrets, and can be made public)
TEST_FIREBASE_API_KEY="${TEST_FIREBASE_API_KEY:-AIzaSyA1QwB8B0CqCu4kjaFx0Z2CPr3XUtXMfoo}"

# Firebase auth domain used by the "emblem-dev" project.
TEST_FIREBASE_DOMAIN="${TEST_FIREBASE_AUTH_DOMAIN:-emblem-dev.firebaseapp.com}"

# The organization to run the tests in
TEST_ORGANIZATION="${TEST_ORGANIZATION:-497965320689}"

# The account to bill charges against
TEST_BILLING_ACCOUNT=${TEST_BILLING_ACCOUNT:-01EA9E-528725-FACCCF}

###########################
# New GCP project IDs #
###########################
SUFFIX=$(openssl rand -hex 8)

# Generate project IDs
PROD_PROJECT="emblem-prod-$SUFFIX"
STAGE_PROJECT="emblem-stage-$SUFFIX"
OPS_PROJECT="emblem-ops-$SUFFIX"

# TEMPORARY: echo project deletion commands
echo "------------------------------------------"
echo "gcloud projects delete $PROD_PROJECT -q | \\"
echo "gcloud projects delete $STAGE_PROJECT -q | \\"
echo "gcloud projects delete $OPS_PROJECT -q"
echo "------------------------------------------"

# Create new gcloud projects
echo 'y' | gcloud projects create $PROD_PROJECT --organization $TEST_ORGANIZATION | \
echo 'y' | gcloud projects create $STAGE_PROJECT --organization $TEST_ORGANIZATION | \
echo 'y' | gcloud projects create $OPS_PROJECT --organization $TEST_ORGANIZATION

# Link billing accounts
gcloud alpha billing projects link $PROD_PROJECT --billing-account $TEST_BILLING_ACCOUNT
gcloud alpha billing projects link $STAGE_PROJECT --billing-account $TEST_BILLING_ACCOUNT
gcloud alpha billing projects link $OPS_PROJECT --billing-account $TEST_BILLING_ACCOUNT


#####################
# Run tested script #
#####################

# Create input string
SETUP_INPUT="$TEST_FIREBASE_API_KEY\n$TEST_FIREBASE_DOMAIN\n$PROD_PROJECT\n$STAGE_PROJECT\n$OPS_PROJECT"

# Disable CI/CD in the tested script
export EMBLEM_SKIP_CICD="true"

# Run tested script
echo $SETUP_INPUT | sh setup_v2.sh
