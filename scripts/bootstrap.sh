#!/bin/bash
set -eu
# TODO: use json policy file instead of inline IAM configs
# TODO: reduce Editor role to only roles needed to deploy Terraform
# TODO: move the state bucket creation from setup to bootstrap

# Services needed for Terraform to managed IAM resources
gcloud services enable iamcredentials.googleapis.com --project $OPS_PROJECT

# Service needed for Terraform to manage resources
gcloud services enable cloudresourcemanager.googleapis.com --project $OPS_PROJECT
gcloud services enable serviceusage.googleapis.com --project $OPS_PROJECT

# Service needed in the ops project to manage app engine in app projects
gcloud services enable appengine.googleapis.com --project $OPS_PROJECT

# Service needed to run Cloud Build in setup
gcloud services enable cloudbuild.googleapis.com --project $OPS_PROJECT

# Create terraform service account
gcloud iam service-accounts create emblem-terraformer \
    --project="$OPS_PROJECT" \
    --description="Service account for deploying resources via Terraform" \
    --display-name="Emblem Terraformer"

# Give cloud build service account token creator on terraform service account policy
OPS_PROJECT_NUMBER=$(gcloud projects list --format='value(PROJECT_NUMBER)' --filter=PROJECT_ID=$OPS_PROJECT)
gcloud iam service-accounts add-iam-policy-binding --project=$OPS_PROJECT \
    emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --member="serviceAccount:${OPS_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
    --role="roles/iam.serviceAccountTokenCreator"

# Apply IAM permissions for Terraform service account

# Ops pernmissions (editor, securityAdmin, and storage.admin)
gcloud projects add-iam-policy-binding $OPS_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/editor"

gcloud projects add-iam-policy-binding $OPS_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/iam.securityAdmin"

gcloud projects add-iam-policy-binding $OPS_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/storage.admin"

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
