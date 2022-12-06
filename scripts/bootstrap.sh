#!/bin/bash

### Bootstrap

# Create terraform service account

gcloud iam service-accounts create emblem-terraformer \
    --project="$OPS_PROJECT" \
    --description="Service account for deploying resources via Terraform" \
    --display-name="Emblem Terraformer"

# Give cloud build token creator
OPS_PROJECT_NUMBER=$(gcloud projects list --format='value(PROJECT_NUMBER)' --filter=PROJECT_ID=$OPS_PROJECT)
gcloud iam service-accounts add-iam-policy-binding \
    emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --member="serviceAccount:${OPS_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
    --role="roles/editor"

# Apply IAM permissions for terraformer to all projects
# Editor and IAM Security admin for OPS
gcloud projects add-iam-policy-binding $OPS_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/editor"

gcloud projects add-iam-policy-binding $OPS_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/iam.securityAdmin"

# editor for STAGE and PROD
gcloud projects add-iam-policy-binding $STAGE_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/editor"

gcloud projects add-iam-policy-binding $PROD_PROJECT \
    --member=serviceAccount:emblem-terraformer@${OPS_PROJECT}.iam.gserviceaccount.com \
    --role="roles/editor"
