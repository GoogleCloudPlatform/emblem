#!/bin/bash
set -eu

OPS_PROJECT_NUMBER=$(gcloud projects list --format='value(PROJECT_NUMBER)' --filter=PROJECT_ID=$OPS_PROJECT)
# Services needed for Terraform to manage resources via service account 

echo -e "Enabling initial required services... \n"
gcloud services enable --project $OPS_PROJECT --async \
    iamcredentials.googleapis.com \
    cloudresourcemanager.googleapis.com \
    serviceusage.googleapis.com \
    appengine.googleapis.com \
    cloudbuild.googleapis.com
    
# Create terraform service account

echo -e "Creating Emblem Terraform service account... \n"
gcloud iam service-accounts create emblem-terraformer \
    --project="$OPS_PROJECT" \
    --description="Service account for deploying resources via Terraform" \
    --display-name="Emblem Terraformer"

# Give cloud build service account token creator on terraform service account policy

echo -e "Setting assigning required IAM roles... \n"
gcloud iam service-accounts add-iam-policy-binding --project=$OPS_PROJECT \
    emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --member="serviceAccount:${OPS_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
    --role="roles/iam.serviceAccountTokenCreator"

# Ops permissions

gcloud projects add-iam-policy-binding $OPS_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/cloudbuild.builds.editor"

gcloud projects add-iam-policy-binding $OPS_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/secretmanager.admin" 

gcloud projects add-iam-policy-binding $OPS_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/pubsub.editor" 

gcloud projects add-iam-policy-binding $OPS_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/iam.serviceAccountAdmin" 

gcloud projects add-iam-policy-binding $OPS_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/artifactregistry.admin"

 gcloud projects add-iam-policy-binding $OPS_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/resourcemanager.projectIamAdmin"

# App permissions for stage and prod

gcloud projects add-iam-policy-binding $STAGE_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/serviceusage.serviceUsageAdmin"

gcloud projects add-iam-policy-binding $STAGE_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/storage.admin"

gcloud projects add-iam-policy-binding $STAGE_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/resourcemanager.projectIamAdmin"

gcloud projects add-iam-policy-binding $STAGE_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/iam.serviceAccountAdmin"

gcloud projects add-iam-policy-binding $STAGE_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/firebase.managementServiceAgent"

gcloud projects add-iam-policy-binding $PROD_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/serviceusage.serviceUsageAdmin"

gcloud projects add-iam-policy-binding $PROD_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/storage.admin"

gcloud projects add-iam-policy-binding $PROD_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/resourcemanager.projectIamAdmin"

gcloud projects add-iam-policy-binding $PROD_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/iam.serviceAccountAdmin"

gcloud projects add-iam-policy-binding $PROD_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/firebase.managementServiceAgent"

# Setup Terraform state bucket

STATE_GCS_BUCKET_NAME="$OPS_PROJECT-tf-states"

if gcloud storage buckets list gs://$STATE_GCS_BUCKET_NAME &> /dev/null ; then
    echo -e "Using existing Terraform remote state bucket: gs://$STATE_GCS_BUCKET_NAME \n"
    gcloud storage buckets update gs://$STATE_GCS_BUCKET_NAME --versioning &> /dev/null
else
    echo -e "Creating Terraform remote state bucket: gs://$STATE_GCS_BUCKET_NAME \n"
    gcloud storage buckets create gs://${STATE_GCS_BUCKET_NAME} --project=$OPS_PROJECT
    echo "Enabling versioning... \n"
    gcloud storage buckets update gs://$STATE_GCS_BUCKET_NAME --versioning
fi

echo -e "Setting storage bucket IAM policy...\n"
gcloud storage buckets add-iam-policy-binding gs://$STATE_GCS_BUCKET_NAME \
    --project=$OPS_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/storage.admin" 

# Add GitHub repo to ops project
REPO_CONNECT_URL="https://console.cloud.google.com/cloud-build/triggers/connect?project=${OPS_PROJECT}"

echo -e "Connect a fork of the Emblem GitHub repo to your ops project via the Cloud Console: $URL \n"
read -n 1 -r -s -p $'Once your forked Emblem repo is connected, please type any key to continue.\n'

continue=1
while [[ ${continue} -gt 0 ]]; do
    read -rp "Please input the GitHub repository owner: " REPO_OWNER
    read -rp "Please input the GitHub repository name: " REPO_NAME
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

echo -e "Adding repo information to project metadata... \n"
gcloud compute project-info add-metadata --project=$OPS_PROJECT \
    --metadata=REPO_NAME=$REPO_NAME

gcloud compute project-info add-metadata --project=$OPS_PROJECT \
    --metadata=REPO_NAME=$REPO_OWNER

# USE THE FOLLOWING TO RETRIEVE VALUES IN SETUP.SH
# gcloud compute project-info describe \
#     --project=$OPS_PROJECT \
#     --format='value[](commonInstanceMetadata.items.REPO_NAME)'

echo -e "Emblem bootstrapping complete! Please run setup.sh \n"