## Running

1. Enable Terraform components:
```
export TF_VAR_setup_cd_system=true
```

2. Set required variables:
```
export TESTING_PROJECT=<YOUR GCP PROJECT>

```

3. Build the testing container
```
gcloud builds submit \
    --config=installation-testing/builds/e2e-deployer.cloudbuild.yaml \
    --project="$TESTING_PROJECT" \
    --substitutions=_REGION="$REGION",_IMAGE_TAG="latest" \
```
