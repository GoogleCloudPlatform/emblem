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

set -eu

export REGION=${REGION:=us-central1}

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

echo "======================================================================"
echo "$(tput bold)Building Lit and Auth container images...$(tput sgr0)"
echo "======================================================================"

export AUTH_BUILD_ID=$(gcloud builds submit --project "${OPS_PROJECT}" --tag "$REGION-docker.pkg.dev/$OPS_PROJECT/website/lit-auth-api" ./server)
export LIT_WEB_BUILD_ID=$(gcloud builds submit --project "${OPS_PROJECT}" --tag "$REGION-docker.pkg.dev/$OPS_PROJECT/website/lit-based-website" .)

echo "======================================================================"
echo "$(tput bold)Deploying Cloud Run services...$(tput sgr0)"
echo "======================================================================"

# Deploys Auth container
gcloud run deploy lit-auth-api \
  --allow-unauthenticated \
  --image "$REGION-docker.pkg.dev/$OPS_PROJECT/website/lit-auth-api:latest" \
  --project "${STAGE_PROJECT}" \
  --region "${REGION}" \
  --port 4000

export AUTH_URL=$(
  gcloud run services describe lit-auth-api \
    --project "${STAGE_PROJECT}" \
    --region ${REGION} \
    --format 'value(status.url)'
)

# Deploys Lit app container
gcloud run deploy lit-based-website \
  --allow-unauthenticated \
  --image "$REGION-docker.pkg.dev/$OPS_PROJECT/website/lit-based-website:latest" \
  --project "${STAGE_PROJECT}" \
  --region "${REGION}" \
  --port 8000

export LIT_URL=$(
  gcloud run services describe lit-based-website \
    --project "${STAGE_PROJECT}" \
    --region ${REGION} \
    --format 'value(status.url)'
)

echo "======================================================================"
echo "$(tput bold)Updating Cloud Run services...$(tput sgr0)"
echo "======================================================================"

gcloud config set project $STAGE_PROJECT

export REDIRECT_URI="${AUTH_URL}/auth/google"
export STAGING_API_URL=$(gcloud run services describe content-api --project "${STAGE_PROJECT}" --region ${REGION} --format 'value(status.url)')
export OPS_PROJECT_NUMBER=$(gcloud projects describe ${OPS_PROJECT} --format "value(projectNumber)")

gcloud run services update lit-based-website \
  --project "${STAGE_PROJECT}" \
  --update-env-vars REDIRECT_URI="${REDIRECT_URI}" \
  --update-env-vars API_URL="${STAGING_API_URL}" \
  --update-env-vars AUTH_API_URL="${AUTH_URL}" \
  --update-env-vars SITE_URL="${LIT_URL}" \
  --update-secrets CLIENT_ID="projects/${OPS_PROJECT_NUMBER}/secrets/client_id_secret:latest" \
  --update-secrets CLIENT_SECRET="projects/${OPS_PROJECT_NUMBER}/secrets/client_secret_secret:latest"

gcloud run services update lit-auth-api \
  --project "${STAGE_PROJECT}" \
  --update-env-vars JWT_SECRET="hello" \
  --update-env-vars REDIRECT_URI="${REDIRECT_URI}" \
  --update-env-vars SITE_URL="${LIT_URL}" \
  --update-secrets CLIENT_ID="projects/${OPS_PROJECT_NUMBER}/secrets/client_id_secret:latest" \
  --update-secrets CLIENT_SECRET="projects/${OPS_PROJECT_NUMBER}/secrets/client_secret_secret:latest"
