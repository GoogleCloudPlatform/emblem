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

# This file will provision end-user authentication
# resources in an already-deployed Emblem instance.

# Check input env variables
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

# Declare variables (calculated from env-var inputs)
PROD_WEBSITE_URL=$(gcloud run services describe website --project ${PROD_PROJECT} --format "value(status.address.url)")
STAGE_WEBSITE_URL=$(gcloud run services describe website --project ${STAGE_PROJECT} --format "value(status.address.url)")

PROD_CALLBACK_URL="${PROD_WEBSITE_URL}/callback"
STAGE_CALLBACK_URL="${STAGE_WEBSITE_URL}/callback"

AUTH_CLIENT_CREATION_URL="https://console.cloud.google.com/apis/credentials/oauthclient?project=${OPS_PROJECT}"
AUTH_CLIENT_CONSENT_SCREEN_URL="https://console.cloud.google.com/apis/credentials/consent?project=${OPS_PROJECT}"


# Configure consent screen
echo "--------------------------------------------"
echo "$(tput setaf 6)Configure OAuth 2.0 consent screen$(tput sgr0)"
echo ""
echo "  Visit this URL in the Cloud Console: $(tput bold)${AUTH_CLIENT_CONSENT_SCREEN_URL}$(tput sgr0)"
echo ""
echo "  Create an $(tput bold)External$(tput sgr0) application, and:"
echo "   - use the $(tput bold)Default Scopes$(tput sgr0)"
echo "   - add yourself as a $(tput bold)Test User$(tput sgr0)"
echo ""
echo "  Otherwise, keep the default settings."
echo ""
python3 -m webbrowser $AUTH_CLIENT_CONSENT_SCREEN_URL
read -p "Once you've configured your consent screen, press $(tput bold)Enter$(tput sgr0) to continue."

# Create OAuth client
echo "--------------------------------------------"
echo "$(tput setaf 6)Create an OAuth 2.0 client$(tput sgr0)"
echo ""
echo "  Visit this URL in the Cloud Console: $(tput bold)${AUTH_CLIENT_CREATION_URL}$(tput sgr0)"
echo ""
echo "  For $(tput bold)Application Type$(tput sgr0), select $(tput bold)Web Application$(tput sgr0)."
echo "  Under $(tput bold)Authorized Redirect URIs$(tput sgr0), add the following URLs:"
echo ""
echo "    ${PROD_CALLBACK_URL}"
echo "    ${STAGE_CALLBACK_URL}"
echo ""
echo "  Then, click $(tput bold)Create$(tput sgr0)."
echo ""
echo "  $(tput bold)Keep the resulting pop-up open!$(tput sgr0) You'll need those values in the next step."
echo ""
python3 -m webbrowser $AUTH_CLIENT_CREATION_URL
read -p "Once you've configured an OAuth client, press $(tput bold)Enter$(tput sgr0) to continue."

# Prompt user to create secret versions
SECRETS_URL="https://console.cloud.google.com/security/secret-manager?project=${OPS_PROJECT}"
echo "--------------------------------------------"
echo "$(tput setaf 6)Configure secret values$(tput sgr0)"
echo ""
echo "  Visit this URL in the Cloud Console: $(tput bold)${SECRETS_URL}$(tput sgr0)"
echo ""
echo "  Add new secret versions to the existing secrets. Set $(tput bold)secret value$(tput sgr0)"
echo "  to the credential values displayed by the $(tput bold)previous step's pop-up$(tput sgr0)."
echo ""
python3 -m webbrowser $SECRETS_URL
read -p "Once you've configured secret versions, press $(tput bold)Enter$(tput sgr0) to continue."

# Update website Cloud Run services with required secrets
OPS_PROJECT_NUMBER=$(gcloud projects describe ${OPS_PROJECT} --format "value(projectNumber)")

AUTH_SECRETS="CLIENT_ID=projects/${OPS_PROJECT_NUMBER}/secrets/client_id_secret:latest"
AUTH_SECRETS="${AUTH_SECRETS},CLIENT_SECRET=projects/${OPS_PROJECT_NUMBER}/secrets/client_secret_secret:latest"

# TODO: fetch the redirect URI dynamically (from HTTP headers) instead of 
#       using env vars, for things like custom domains and load balancers.
#       See https://github.com/GoogleCloudPlatform/emblem/issues/277

set -x

gcloud beta run services update website \
    --update-env-vars "REDIRECT_URI=${STAGE_CALLBACK_URL}" \
    --update-secrets "${AUTH_SECRETS}" \
    --project "$STAGE_PROJECT"
gcloud beta run services update website \
    --update-env-vars "REDIRECT_URI=${PROD_CALLBACK_URL}" \
    --update-secrets "${AUTH_SECRETS}" \
    --project "$PROD_PROJECT"
