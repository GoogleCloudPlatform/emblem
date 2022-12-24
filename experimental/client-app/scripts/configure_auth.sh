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

export REGION=${REGION:=us-central1}

# Declare variables (calculated from env-var inputs)
STAGE_AUTH_API_URL=$(gcloud run services describe lit-auth-api --project "${STAGE_PROJECT}" --region "${REGION}" --format "value(status.address.url)")
STAGE_CALLBACK_URL="${STAGE_WEBSITE_URL}/auth/google"

AUTH_CLIENT_CREATION_URL="https://console.cloud.google.com/apis/credentials/oauthclient?project=${OPS_PROJECT}"
AUTH_CLIENT_CONSENT_SCREEN_URL="https://console.cloud.google.com/apis/credentials/consent?project=${OPS_PROJECT}"

# Configure consent screen
echo "--------------------------------------------"
echo "$(tput setaf 6)Configure OAuth 2.0 consent screen$(tput sgr0)"
echo ""
if [[ $CLOUD_SHELL ]]; then
    echo "  Open the Cloud Console by clicking this URL: $(tput bold)https://console.cloud.google.com/?project=${OPS_PROJECT}&cloudshell=true$(tput sgr0)"
    echo "  In the Cloud Console Search bar, search for 'OAuth Consent Screen' and click on the $(tput bold)OAuth consent screen$(tput sgr0) page. "
else
    echo "  Visit this URL in the Cloud Console: $(tput bold)${AUTH_CLIENT_CONSENT_SCREEN_URL}$(tput sgr0)"
fi
echo
echo "  Under User type, select $(tput bold)External$(tput sgr0) and click $(tput bold)Create$(tput sgr0)."
echo "  Under App information, enter values for $(tput bold)App name$(tput sgr0) and $(tput bold)User support email$(tput sgr0)."
echo "  At the bottom of the page, enter a $(tput bold)Developer contact email$(tput sgr0), then click $(tput bold)Save and continue$(tput sgr0)."
echo
echo "  Under Scopes, leave the default scopes and click $(tput bold)Save and continue$(tput sgr0)."
echo
echo "  Under $(tput bold)Test Users$(tput sgr0), add your email as a $(tput bold)Test User$(tput sgr0) and click $(tput bold)Save and continue$(tput sgr0)."
echo
if [[ $CLOUD_SHELL ]]; then
    echo
else
    python3 -m webbrowser $AUTH_CLIENT_CONSENT_SCREEN_URL
fi
read -p "Once you've configured your consent screen, press $(tput bold)Enter$(tput sgr0) to continue."

# Create OAuth client
echo "--------------------------------------------"
echo "$(tput setaf 6)Create an OAuth 2.0 client$(tput sgr0)"
echo ""
if [[ $CLOUD_SHELL ]]; then
    echo "  In the Cloud Console Search bar, search for 'OAuth Credentials' and click on the $(tput bold)Credentials$(tput sgr0) page. "
else
    echo "  Visit this URL in the Cloud Console: $(tput bold)${AUTH_CLIENT_CREATION_URL}$(tput sgr0)"
fi
echo ""
echo "  Click CREATE CREDENTIALS and select $(tput bold)OAuth client ID$(tput sgr0). "
echo "  For Application Type, select $(tput bold)Web Application$(tput sgr0)."
echo "  Under Authorized Redirect URIs, add the following URLs:"
echo ""

if [ "${PROD_PROJECT}" != "${STAGE_PROJECT}" ]; then
echo "    ${PROD_CALLBACK_URL}"
fi

echo "    ${STAGE_CALLBACK_URL}"
echo ""
echo "  Click $(tput bold)Create$(tput sgr0). You will see a pop-up displaying your client ID and client secret values. You'll need these values in the next step."
echo "  To retrieve the values after closing the pop-up, click on the name of your client under $(tput bold)OAuth 2.0 Client IDs$(tput sgr0). The client ID and client secret are located in the upper right corner of the page." 
echo ""
if [[ $CLOUD_SHELL ]]; then
    echo ""
else
    python3 -m webbrowser $AUTH_CLIENT_CREATION_URL
fi
read -p "Once you've configured an OAuth client, press $(tput bold)Enter$(tput sgr0) to continue."

# Prompt user to create secret versions
SECRETS_URL="https://console.cloud.google.com/security/secret-manager?project=${OPS_PROJECT}"
echo "--------------------------------------------"
echo "$(tput setaf 6)Configure secret values$(tput sgr0)"
echo ""
if [[ $CLOUD_SHELL ]]; then
    echo "  In the Cloud Console Search bar, search for 'Secret Manager' and click on the $(tput bold)Secret Manager$(tput sgr0) page."
else
    echo "  Visit this URL in the Cloud Console: $(tput bold)${SECRETS_URL}$(tput sgr0)"
fi
echo ""
echo "  Create a secret by clicking +CREATE SECRET and name it $(tput bold)client_id_secret$(tput sgr0)."
echo "  If the secret already exists, open $(tput bold)client_id_secret$(tput sgr0) and click +NEW VERSION. "
echo "  In the $(tput bold)Secret value$(tput sgr0) field, enter the $(tput bold)client ID$(tput sgr0) from the previous step. "
echo "  Click $(tput bold)Add new version$(tput sgr0)."
echo "                                                "
echo "  Repeat the steps above for $(tput bold)client_secret_secret$(tput sgr0)."
echo "  In the $(tput bold)Secret value$(tput sgr0) field, enter the $(tput bold)client secret$(tput sgr0) from the previous step. "
echo ""
if [[ $CLOUD_SHELL ]]; then
    echo ""
else
    python3 -m webbrowser $SECRETS_URL
fi
read -p "Once you've configured secret versions, press $(tput bold)Enter$(tput sgr0) to continue."

# Update website Cloud Run services with required secrets
OPS_PROJECT_NUMBER=$(gcloud projects describe ${OPS_PROJECT} --format "value(projectNumber)")

AUTH_SECRETS="CLIENT_ID=projects/${OPS_PROJECT_NUMBER}/secrets/client_id_secret:latest"
AUTH_SECRETS="${AUTH_SECRETS},CLIENT_SECRET=projects/${OPS_PROJECT_NUMBER}/secrets/client_secret_secret:latest"

gcloud run services update lit-based-website \
    --update-env-vars "REDIRECT_URI=${STAGE_CALLBACK_URL}" \
    --update-secrets "${AUTH_SECRETS}" \
    --region "${REGION}" \
    --project "${STAGE_PROJECT}"

echo
echo "The application is now configured for end-user authentication."
