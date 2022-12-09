#!/bin/bash
set -eu

# Formatting variables
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Check env variables are not empty strings
if [[ -z "${PROD_PROJECT:-}" ]]; then
    echo -e "---\n${RED}Emblem bootstrap error:${NC} Please set the $(tput bold)PROD_PROJECT$(tput sgr0) environment variable \n---"
    exit 1
elif [[ -z "${STAGE_PROJECT:-}" ]]; then
    echo -e "---\n${RED}Emblem bootstrap error:${NC} Please set the $(tput bold)STAGE_PROJECT$(tput sgr0) environment variable \n---"
    exit 1
elif [[ -z "${OPS_PROJECT:-}" ]]; then
    echo -e "---\n${RED}Emblem bootstrap error:${NC} Please set the $(tput bold)OPS_PROJECT$(tput sgr0) environment variable \n---"
    exit 1
fi

echo -e "Bootstrapping Emblem...\n"

# Set other variables
OPS_PROJECT_NUMBER=$(gcloud projects list --format='value(PROJECT_NUMBER)' --filter=PROJECT_ID=$OPS_PROJECT)
if [[ -z "${OPS_PROJECT_NUMBER}" ]]; then
    echo -e "---\n${RED}Emblem bootstrap error:${NC} Could not retrieve project number for $(tput bold)${OPS_PROJECT}$(tput sgr0).\n---"
    exit 1
fi

EMBLEM_TF_SERVICE_ACCOUNT=emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com
BUILD_SERVICE_ACCOUNT=${OPS_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com
# Services needed for Terraform to manage resources via service account 

echo -e "\xe2\x88\xb4 Enabling initial required services... \n"
gcloud services enable --project $OPS_PROJECT --async \
    iamcredentials.googleapis.com \
    cloudresourcemanager.googleapis.com \
    serviceusage.googleapis.com \
    appengine.googleapis.com \
    cloudbuild.googleapis.com &> /dev/null

# Create terraform service account
if gcloud iam service-accounts describe \
    $EMBLEM_TF_SERVICE_ACCOUNT \
    --project $OPS_PROJECT &> /dev/null ; then
        echo -e "\xe2\x88\xb4 Using existing Emblem Terraform service account:  $EMBLEM_TF_SERVICE_ACCOUNT \n"
else
    echo -e "\xe2\x88\xb4 Creating Emblem Terraform service account: $EMBLEM_TF_SERVICE_ACCOUNT \n"
    gcloud iam service-accounts create emblem-terraformer \
        --project="$OPS_PROJECT" \
        --description="Service account for deploying resources via Terraform" \
        --display-name="Emblem Terraformer"
fi

# Give cloud build service account token creator on terraform service account policy
echo -e "\xe2\x88\xb4 Updating Terraform service account IAM policy... \n"
gcloud iam service-accounts add-iam-policy-binding --project=$OPS_PROJECT \
    $EMBLEM_TF_SERVICE_ACCOUNT \
    --member="serviceAccount:${BUILD_SERVICE_ACCOUNT}" \
    --role="roles/iam.serviceAccountTokenCreator" &> /dev/null

# Ops permissions
echo -e "\xe2\x88\xb4 Updating ops project IAM policy... \n"
gcloud projects add-iam-policy-binding $OPS_PROJECT \
    --member=serviceAccount:$EMBLEM_TF_SERVICE_ACCOUNT \
    --role="roles/cloudbuild.builds.editor" &> /dev/null

gcloud projects add-iam-policy-binding $OPS_PROJECT \
    --member=serviceAccount:$EMBLEM_TF_SERVICE_ACCOUNT \
    --role="roles/secretmanager.admin" &> /dev/null

gcloud projects add-iam-policy-binding $OPS_PROJECT \
    --member=serviceAccount:$EMBLEM_TF_SERVICE_ACCOUNT \
    --role="roles/pubsub.editor" &> /dev/null

gcloud projects add-iam-policy-binding $OPS_PROJECT \
    --member=serviceAccount:$EMBLEM_TF_SERVICE_ACCOUNT \
    --role="roles/iam.serviceAccountAdmin" &> /dev/null

gcloud projects add-iam-policy-binding $OPS_PROJECT \
    --member=serviceAccount:$EMBLEM_TF_SERVICE_ACCOUNT \
    --role="roles/artifactregistry.admin" &> /dev/null

 gcloud projects add-iam-policy-binding $OPS_PROJECT \
    --member=serviceAccount:$EMBLEM_TF_SERVICE_ACCOUNT \
    --role="roles/resourcemanager.projectIamAdmin" &> /dev/null

# App permissions for stage and prod

echo -e "\xe2\x88\xb4 Updating stage project IAM policy... \n"
gcloud projects add-iam-policy-binding $STAGE_PROJECT \
    --member=serviceAccount:$EMBLEM_TF_SERVICE_ACCOUNT \
    --role="roles/serviceusage.serviceUsageAdmin" &> /dev/null

gcloud projects add-iam-policy-binding $STAGE_PROJECT \
    --member=serviceAccount:$EMBLEM_TF_SERVICE_ACCOUNT \
    --role="roles/storage.admin" &> /dev/null

gcloud projects add-iam-policy-binding $STAGE_PROJECT \
    --member=serviceAccount:$EMBLEM_TF_SERVICE_ACCOUNT \
    --role="roles/resourcemanager.projectIamAdmin" &> /dev/null

gcloud projects add-iam-policy-binding $STAGE_PROJECT \
    --member=serviceAccount:$EMBLEM_TF_SERVICE_ACCOUNT \
    --role="roles/iam.serviceAccountAdmin" &> /dev/null

gcloud projects add-iam-policy-binding $STAGE_PROJECT \
    --member=serviceAccount:$EMBLEM_TF_SERVICE_ACCOUNT \
    --role="roles/firebase.managementServiceAgent" &> /dev/null

echo -e "\xe2\x88\xb4 Updating prod project IAM policy... \n"
gcloud projects add-iam-policy-binding $PROD_PROJECT \
    --member=serviceAccount:$EMBLEM_TF_SERVICE_ACCOUNT \
    --role="roles/serviceusage.serviceUsageAdmin" &> /dev/null

gcloud projects add-iam-policy-binding $PROD_PROJECT \
    --member=serviceAccount:$EMBLEM_TF_SERVICE_ACCOUNT \
    --role="roles/storage.admin" &> /dev/null

gcloud projects add-iam-policy-binding $PROD_PROJECT \
    --member=serviceAccount:$EMBLEM_TF_SERVICE_ACCOUNT \
    --role="roles/resourcemanager.projectIamAdmin" &> /dev/null

gcloud projects add-iam-policy-binding $PROD_PROJECT \
    --member=serviceAccount:$EMBLEM_TF_SERVICE_ACCOUNT \
    --role="roles/iam.serviceAccountAdmin" &> /dev/null

gcloud projects add-iam-policy-binding $PROD_PROJECT \
    --member=serviceAccount:$EMBLEM_TF_SERVICE_ACCOUNT \
    --role="roles/firebase.managementServiceAgent" &> /dev/null

# Setup Terraform state bucket

STATE_GCS_BUCKET_NAME="$OPS_PROJECT-tf-states"

if gcloud storage buckets list gs://$STATE_GCS_BUCKET_NAME &> /dev/null ; then
    echo -e "\xe2\x88\xb4 Using existing Terraform remote state bucket: gs://$STATE_GCS_BUCKET_NAME \n"
    gcloud storage buckets update gs://$STATE_GCS_BUCKET_NAME --versioning &> /dev/null
else
    echo -e "\xe2\x88\xb4 Creating Terraform remote state bucket: gs://$STATE_GCS_BUCKET_NAME \n"
    gcloud storage buckets create gs://${STATE_GCS_BUCKET_NAME} --project=$OPS_PROJECT
    echo "\xe2\x88\xb4 Enabling versioning... \n"
    gcloud storage buckets update gs://$STATE_GCS_BUCKET_NAME --versioning
fi

echo -e "\xe2\x88\xb4 Setting storage bucket IAM policy for Terraform service account...\n"
gcloud storage buckets add-iam-policy-binding gs://$STATE_GCS_BUCKET_NAME \
    --project=$OPS_PROJECT \
    --member=serviceAccount:$EMBLEM_TF_SERVICE_ACCOUNT \
    --role="roles/storage.admin" &> /dev/null

# Add GitHub repo to ops project
REPO_CONNECT_URL="https://console.cloud.google.com/cloud-build/triggers/connect?project=${OPS_PROJECT}"

echo -e "${GREEN}\xE2\x9E\xA8 Connect a fork of the Emblem GitHub repo to your ops project via the Cloud Console:${NC} $(tput bold)$REPO_CONNECT_URL$(tput sgr0) \n"
read -n 1 -r -s -p $'Once your forked Emblem repo is connected, please type any key to continue.\n'

continue=1
while [[ ${continue} -gt 0 ]]; do
    read -rp "Please input the GitHub repository owner: " REPO_OWNER
    read -rp "Please input the GitHub repository name: " REPO_NAME
    echo -e "\n"
    read -rp "Is this the correct repository URL? $(tput bold)https://github.com/${REPO_OWNER}/${REPO_NAME}$(tput sgr0)? (Y/n) " yesno

    case "$yesno" in
    [yY][eE][sS]|[yY]|"") 
        continue=0
        ;;
    *)
        continue=1
        ;;
    esac
done

echo -e "\n\xe2\x88\xb4 Adding repo information to project metadata... \n"
gcloud compute project-info add-metadata --project=$OPS_PROJECT \
    --metadata=REPO_NAME=$REPO_NAME &> /dev/null

gcloud compute project-info add-metadata --project=$OPS_PROJECT \
    --metadata=REPO_OWNER=$REPO_OWNER &> /dev/null

# USE THE FOLLOWING TO RETRIEVE VALUES IN SETUP.SH
# gcloud compute project-info describe \
#     --project=$OPS_PROJECT \
#     --format='value[](commonInstanceMetadata.items.REPO_NAME)'

echo -e "\n${GREEN}Emblem bootstrapping complete! Please run setup.sh${NC} \n"