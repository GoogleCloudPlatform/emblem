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
gcloud pubsub topics delete nightly_builds \
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

echo "###################################################"
echo "#                   End cleanup                   #"
echo "###################################################"
