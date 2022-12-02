# Automated Tests

These tests run automatically once you have set up a working instance of Emblem.

## Content API

Content API unit tests run automatically [on pull requests to `main`](/terraform/modules/ops/testing.tf#:~:text=resource%20%22google_cloudbuild_trigger%22%20%22api_unit_tests%22).

## Pipelines / Delivery System
  
The **delivery system** can _optionally_ be covered by an automatic **End-to-End (E2E) Test**.

This test uses Cloud Build to run the [setup/deployment script](/setup.sh) on a nightly basis, and checks that it completes without any errors.
  
Follow the [instructions](/installation-testing/README.md) in the `installation-testing` directory to enable this test.

## Website

The [Website](/docs/website.md) component is covered by automatic **End-to-End (E2E) Tests**.
  
These tests run the website in a [Docker container](/ops/e2e-runner), and check that the website's routes load without any errors.

> **Note:** this Docker container is rebuilt [nightly](/terraform/modules/ops/testing.tf#:~:text=resource%20%22google_cloudbuild_trigger%22%20%22e2e_nightly_tests%22) _and_ [on pushes/merges to `main`](/terraform/modules/ops/testing.tf#:~:text=resource%20%22google_cloudbuild_trigger%22%20%22e2e_testing_build_runner%22).
>
> We kept nightly {container builds, test runs} separate so that E2E tests run even if the container build fails.

These tests run automatically [on pull requests to `main`](/terraform/modules/ops/testing.tf#:~:text=resource%20%22google_cloudbuild_trigger%22%20%22web_e2e_test%22).


> **Note:** we are working on adding a nightly test runner as well

# Manually Running Tests

This guide assumes you have a working instance of Emblem.

## API Testing

See [Content API: Running Local Tests](content-api.md#running-local-tests).

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
