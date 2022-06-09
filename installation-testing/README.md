# Installation Testing

This folder contains resources used to test that Emblem is correctly provisioned on top of a (somewhat pre-configured) Google Cloud project.

**Note:**
> This is an _optional_ sub-component of the Emblem project. You do **not** need to configure this component to use the application.


## Setup
Follow the steps below to set up these tests.

1. Enable Terraform components:
```
export TF_VAR_setup_cd_system=true
```

2. Set required variables:
```
export TESTING_PROJECT=<YOUR GCP PROJECT>
```

3. Run Terraform from the `installation-testing` directory:
```
terraform -chdir="terraform/modules/emblem-app" init
terraform -chdir="terraform/modules/emblem-app" apply

terraform -chdir="terraform/modules/ops" init
terraform -chdir="terraform/modules/ops" apply
```

4. Build the testing container
```
gcloud builds submit \
    --config=installation-testing/builds/e2e-deployer.cloudbuild.yaml \
    --project="$TESTING_PROJECT" \
    --substitutions=_REGION="$REGION",_IMAGE_TAG="latest" \
```

5. Set up the [core Emblem application](/docs/tutorials/setup-quickstart.md).

## Useful links

See [Emblem's testing documentation](/docs/testing.md) for more information about testing.
