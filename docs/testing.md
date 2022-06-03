
# Manually Running Tests

This guide assumes you have a working instance of Emblem.

## API Testing

See [Content API: Running Local Tests](/docs/content-api.md#running-local-tests).

To run the tests remotely via the Cloud Build configuration:

```sh
# Navigate to the repository root.
# Create a service account. This operates as a mock API user.
test_service_account="test-identity@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com"
gcloud builds submit \
  --config ops/unit-tests.cloudbuild.yaml \
  --substitutions "_DIR=content-api,_SERVICE_ACCOUNT=$test_service_account"
```

## Website Testing

To run the tests remotely via the Cloud Build configuration:

```sh
# Navigate to the repository root.
# Create a service account. This operates as a mock site user.
test_service_account="test-identity@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com"
gcloud builds submit \
  --config ops/unit-tests.cloudbuild.yaml \
  --substitutions "_DIR=website,_SERVICE_ACCOUNT=$test_service_account"
```

## Deployment Testing

If you have a running instance of Emblem, you can trigger deployment by building
a container image and pushing to the Artifact Registry instance for the service.

When Artifact Registry receives the container image, it will publish a Pub/Sub
message that will start a series of Cloud Build operations that will deploy the
container via a canary rollout process.

Triggering a Content API deployment:

```sh
cd content-api
REGION=us-central1
PROJECT_ID=example-emblem-ops
gcloud builds submit --tag \
  ${_REGION}-docker.pkg.dev/${PROJECT_ID}/content-api/content-api:manual
```

Triggering a Web deployment:

```sh
cd website
REGION=us-central1
PROJECT_ID=example-emblem-ops
cp -R client-libs client-libs
gcloud builds submit --tag \
  ${_REGION}-docker.pkg.dev/${PROJECT_ID}/website/website:manual
```

## Terraform Testing

Use `terraform/clean_project_setup.sh` to create a new projects and run through
the end-to-end setup process.
