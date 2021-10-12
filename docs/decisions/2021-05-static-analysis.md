# Use GitHub Actions for Static Analysis

* **Status:** approved
* **Last Updated:** 2021-05
* **Builds on:** [Cloud Build for Cloud Resources](2021-05-pipelines.md)
* **Objective:** Where should automated static analysis be run?

## Context & Problem Statement

We've previously decided to use Cloud Build to manage Cloud Resources, but there are some user experience challenges compared to GitHub Actions.

## Considered Options

* Option 1: Cloud Build
* Option 2: GitHub Actions

## Decision

Chosen option [Option 2: GitHub Actions]

For automated work such as static analysis and unit testing, the trade-offs are different: we're not concerned with Cloud security in the same way.

GitHub Actions has simpler syntax, deeper GitHub integration, and thriving ecosystem of examples.

### Expected Consequences <!-- optional -->

* Need to understand multiple "CI" products
* Reduce feedback to the Cloud Build product

## Links

### Timeline

* [#20: docs: add design philsophy and static analysis guidelines](https://github.com/GoogleCloudPlatform/emblem/pull/20)
* [#50: Add code style support for Terraform](https://github.com/GoogleCloudPlatform/emblem/issues/50)
* [#128: chore(style-python): add black for python linting](https://github.com/GoogleCloudPlatform/emblem/pull/128)
