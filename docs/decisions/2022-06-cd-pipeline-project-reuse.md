# Use recycled GCP projects in Delivery CI pipeline

* **Status:** approved
* **Last Updated:** 2022-06-01
* **Objective:** determine which Google Cloud (GCP) projects delivery testing systems should run against

## Context & Problem Statement

Thoroughly testing our **Delivery** component requires having **test projects** that we can (attempt to) deploy Emblem to.

These projects must be created somehow.

## Priorities & Constraints

1. Some GCP environments have IAM policies prohibiting users from creating new projects.
2. Testing against ephemeral projects might lead to:
   1. fewer flakes
   2. less dependence on pre-existing project state
3. Creating ephemeral projects programmatically requires allowing non-human IAM principals (such as _Service Accounts_) to create new GCP projects.

## Considered Options

* **Option 1:** Pre-provision long-lived projects manually beforehand
* **Option 2:** Create ephemeral projects programmatically at test time

## Decision

We chose to **pre-provision long-lived projects manually beforehand**.

This was largely due to organization-level constraints that make it difficult (if not impossible) for our team to _programmatically_ create new GCP projects.

### Expected Consequences

This may cause a higher degree of CI pipeline flakiness, in both directions.
* **False passes** may occur if tests depend on GCP resources within a project that are undeclared in Terraform.
* **False failures** may occur if the project's previous state breaks our tools'/Terraform's attempts at automated state management.

## Links

Related Issue
* [Determine steps to test delivery system](https://github.com/GoogleCloudPlatform/emblem/issues/347)
