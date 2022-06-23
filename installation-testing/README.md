# Installation Testing

This folder contains resources used to test that Emblem is correctly provisioned on top of a (somewhat pre-configured) Google Cloud project.

**Note:**
> This is an _optional_ sub-component of the Emblem project. You do **not** need to configure this component to use the application.

## Prerequisites

Make sure you've [set up an Emblem instance](/docs/tutorials/setup-quickstart.md) **before** following this tutorial.

## Setup
Follow the steps below to set up these tests.

1. Enable Terraform components:
```
export TF_VAR_setup_cd_system=true
```

2. Set required variables:
```
# Common regions include `us-central1`, `europe-west6` and `asia-east1`.
# See the page below for a full list:
#   https://cloud.google.com/about/locations
export REGION=<YOUR GCP REGION>

export TESTING_PROJECT=<YOUR GCP PROJECT>

# Expose testing project ID to Terraform
export TF_VAR_project_id=$TESTING_PROJECT

# Use the same project for "ops" and "staging"
export TF_VAR_ops_project_id=$TESTING_PROJECT

# Configure GitHub {user, repository} name
export TF_VAR_repo_owner=<YOUR GITHUB USER/ORG NAME>
export TF_VAR_repo_name=emblem

# Specify the triggering Pub/Sub topic ID (default: nightly)
export TF_VAR_deploy_trigger_topic_id=nightly
```

3. Run Terraform from the `installation-testing` directory:
```
terraform -chdir="terraform/modules/emblem-app" init
terraform -chdir="terraform/modules/emblem-app" apply

terraform -chdir="terraform/modules/ops" init
terraform -chdir="terraform/modules/ops" apply
```

4. Build the testing container:
```
gcloud builds submit \
    --config=installation-testing/builds/e2e-deployer.cloudbuild.yaml \
    --project="$TESTING_PROJECT" \
    --substitutions=_REGION="$REGION",_IMAGE_TAG="latest"
```

## Useful links

See [Emblem's testing documentation](/docs/testing.md) for more information about testing.
