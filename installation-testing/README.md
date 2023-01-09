# Installation Testing

This folder contains resources used to test that Emblem is correctly provisioned on top of a (somewhat pre-configured) Google Cloud project.

**Notes:**
> This is an _optional_ sub-component of the Emblem project. You do **not** need to configure this component to use the application.

> These tests must be run against a Google Cloud Project. We recommend creating a **separate project** for this instead of reusing the ones created for the core Emblem application.

## Prerequisites

Make sure you've [set up an Emblem instance](/README.md#streamlined-setup) **before** following this tutorial.

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
```

3. Run Terraform from the `installation-testing` directory:
```
terraform -chdir="installation-testing/terraform/modules/emblem-app" init
terraform -chdir="installation-testing/terraform/modules/emblem-app" apply

terraform -chdir="installation-testing/terraform/modules/ops" init
terraform -chdir="installation-testing/terraform/modules/ops" apply
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
