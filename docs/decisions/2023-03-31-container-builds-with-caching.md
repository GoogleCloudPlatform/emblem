# Container Builds with Caching

* **Status:** approved
* **Last Updated:** 2023-03-31
* **Builds on:** [Use Cloud Build for Cloud Resource management](2021-05-pipelines.md)
* **Objective:** Build container images efficiently with layer caching inside Cloud Build.

## Context & Problem Statement

We originally presumed container image builds would use Cloud Build, because we
need application container images in Google Container Registry or Artifact
Registry for ease of deploying to Cloud Run. As part of that, we defaulted to
use of docker to build container images, and did not think to question it.

There are other ways to build containers. In [Passing Tests for Playwright Dependency Updates](2023-03-31-playwright-dependencies.md), a decision has been made to use
just-in-time container image builds for a customized testing tool as part of our
end-to-end testing pipeline.

We want to make sure the impact of just-in-time builds is minimized. Cloud Build
recommends [caching to speed up builds](https://cloud.google.com/build/docs/optimize-builds/speeding-up-builds).

## Priorities & Constraints <!-- optional -->

* Use standard, container-native tooling
* Minimize the complexity of a caching implementation
* Minimize the infrastructure of a caching implementation
* Minimize the speed of test builds

## Considered Options

Cloud Build documentation recommends two options for caching with container builds:

* Option 1: Docker with --cache-from
* Option 2: Kaniko with caching

## Decision

Chosen option [Option 2] Kaniko with caching.

Kaniko was faster, less complex, and had a better UX related to caching and
interacting with Artifact Registry. Where we need container builds with carefully
minimized build time, we will use Kaniko to build the container image.

### Kaniko

```yaml
  - id: 'Build Test Runner (Kaniko)'
    name: 'gcr.io/kaniko-project/executor:latest'
    args:
      - "--destination=${_REGION}-docker.pkg.dev/${PROJECT_ID}/e2e-testing/runner:kaniko-${_E2E_RUNNER_SHA}"
      - "--cache=true"
    dir: ops/e2e-runner
```

### Docker

```yaml
  - id: 'Build Test Runner (Docker)'
    name: 'gcr.io/cloud-builders/docker'
    script: |
      docker pull "${REGION}-docker.pkg.dev/${PROJECT_ID}/e2e-testing/runner:docker-${E2E_RUNNER_SHA}" || exit 0
      docker build . -t "${REGION}-docker.pkg.dev/${PROJECT_ID}/e2e-testing/runner:docker-${E2E_RUNNER_SHA}" \
        --cache-from "${REGION}-docker.pkg.dev/${PROJECT_ID}/e2e-testing/runner:docker-${E2E_RUNNER_SHA}"
      docker push "${REGION}-docker.pkg.dev/${PROJECT_ID}/e2e-testing/runner:docker-${E2E_RUNNER_SHA}"
    dir: ops/e2e-runner
    env:
      - "REGION=${_REGION}"
      - "E2E_RUNNER_SHA=${_E2E_RUNNER_SHA}"
      - "PROJECT_ID=${PROJECT_ID}"
```

### Analysis

|  Tool  | 1st Build | 2nd Build | 3rd Build | Step # | Line # | Char # |
| ------ | --------- | --------- | --------- | ------ | ------ | ------ |
| Kaniko |   2:35    |  00:23    |  00:30    |   1    |   5    |  248   |
| Docker |   2:30    |  00:49    |  00:57    |   1    |   11   |  658   |

Qualitatively,

* Kaniko checks access to push image after pull and before build, meaning it saves
  minutes of build time where docker completes the build then fails when docker
  push is attempted. (It's possible an additional docker command could be run to
  verify push configuration and access, at the cost of yet more complexity.)
* Kaniko error log output on push failure is more actionable
* Kaniko log output about cache utilization stands out more clearly

### Expected Consequences <!-- optional -->

[Kaniko](https://github.com/GoogleContainerTools/kaniko) is a Google-maintained
project but doesn't have the same level of focus and community investment as docker.
As a result, it is more likely to have edge case bugs. For the needs of the Emblem
project, it is acceptable as long as the specific container images we need to build
will work.

### Revisiting this Decision <!-- optional -->

If we have trouble with build time, build success, or new features come out that
make using another tool compelling, we will revisit this change. Switching cost
is low.

## Links

* [#822](https://github.com/GoogleCloudPlatform/emblem/pull/822)
