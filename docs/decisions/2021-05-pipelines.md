# Use Cloud Build for Cloud Resource management

* **Status:** approved
* **Last Updated:** 2021-05
* **Objective:** Determine the platform for ops automation.

## Context & Problem Statement

We need an environment for continuous delivery and other Cloud resource management.

## Priorities & Constraints <!-- optional -->

* Needs IAM privileges to access Cloud resources
* Needs to support PR checks and nightly builds
* Has two critical roles:
  1. Automated testing for project maintenance
  1. Including CI/CD in complex demos

## Considered Options

* Option 1: Cloud Build
* Option 2: GitHub Actions
* Option 3: Internal Google CI tooling

## Decision

Chosen option [Option 1: Cloud Build]

Cloud Build has the least overhead and security risk in gaining IAM access to other Google Cloud resources. There is no need to export service account keys.

It has GitHub integration, PR checks, & nightly builds.

It is a product that external contributors can use.

### Expected Consequences <!-- optional -->

* Cloud Build's integration with GitHub means untrusted contributors cannot view build logs
* Cloud Build's identity implementation does not allow easy invocation of authentication-only Cloud Run services or HTTP Cloud Functions
* The Cloud Build UI assumes workload operations are self-contained in a single build, so our plans around orchestrating some operations across multiple builds will have some extra visibility challenges.

## Links

* https://github.com/GoogleCloudPlatform/emblem/issues/26
