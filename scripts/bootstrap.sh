#!/bin/bash
set -eu
# TODO: reduce Editor role to only roles needed to deploy Terraform
# TODO: move the state bucket creation from setup to bootstrap

OPS_PROJECT_NUMBER=$(gcloud projects list --format='value(PROJECT_NUMBER)' --filter=PROJECT_ID=$OPS_PROJECT)
# Services needed for Terraform to manage resources via service account 

gcloud services enable --project $OPS_PROJECT --async \
    iamcredentials.googleapis.com \
    cloudresourcemanager.googleapis.com \
    serviceusage.googleapis.com \
    appengine.googleapis.com \
    cloudbuild.googleapis.com 
    
# Create terraform service account
gcloud iam service-accounts create emblem-terraformer \
    --project="$OPS_PROJECT" \
    --description="Service account for deploying resources via Terraform" \
    --display-name="Emblem Terraformer"

# Give cloud build service account token creator on terraform service account policy

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

# App permissions for stage and prod (editor, securityAdmin, firebase.managementServiceAgent)
gcloud projects add-iam-policy-binding $STAGE_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/editor"

gcloud projects add-iam-policy-binding $STAGE_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/iam.securityAdmin"

gcloud projects add-iam-policy-binding $STAGE_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/firebase.managementServiceAgent"

gcloud projects add-iam-policy-binding $PROD_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/editor"

gcloud projects add-iam-policy-binding $PROD_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/iam.securityAdmin"

gcloud projects add-iam-policy-binding $PROD_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/firebase.managementServiceAgent"
