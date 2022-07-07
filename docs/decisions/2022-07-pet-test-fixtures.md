# Allow "pet" test fixtures

* **Status:** approved
* **Last Updated:** 2022-07

## Context & Problem Statement

Emblem evolved to use "pet" test fixtures in end-to-end (E2E) test runs. These include resources such as Google Cloud projects, Cloud Storage buckets, container images in Artifact Registry, and Cloud Run services.

We decided to investigate whether we should migrate our fixtures to a "cattle"-based model.

## Priorities

Ideally, our test fixtures would be designed such that:

* Test infrastructure is quick to set up.
* Test infrastructure is documented (e.g. via Terraform files).
* Tests themselves are quick to write.
* Both tests and their infrastructure require minimal maintenance.
* Tests are runnable by multiple [teams of] developers in parallel.
* Tests cover as much of the application surface as possible.
* Tests allow developers and contributors to quickly identify root causes of bugs.

Of course, some of these goals are mutually exclusive: supporting parallel test runs often increases the cost of writing (and in some cases maintaining) tests and test infrastructure.

## Constraints

### Some resources MUST be pets
While most of Emblem's Google Cloud resources are provisioned programmatically using Terraform, some (such as the Google Cloud projects themselves) are provisioned manually.

> Consequently, we can't rely entirely on automated provisioning systems (at least, not without significant further engineering work) to spin these up and down arbitrarily.

### Emblem is owned by a single team
While Emblem is designed with a service-oriented architecture, all of Emblem's components are (currently) owned by the same team.

> Consequently, optimizing our test fixtures for multi-team collaboration isn't as important as minimizing test development/maintenance costs.

## Considered Options

In this case, we have a _continuous spectrum_ of options. Thus, the "options" below are more _extremes_ than options:

* **Extreme 1:** All fixtures are centralized "pets"
* **Extreme 2:** All fixtures are ephemeral "cattle"

## Decision

We'll use _programmatically provisioned_ fixture resources wherever practical. These resources can be made ephemeral ("cattle") if necessary.

In some situations, _manual provisioning_ of centralized ("pet") resources will be simpler to implement (if not outright required). Usually, these resources **cannot** be made ephemeral and will need to be reused between test runs.

### Rationale

The entire Emblem application is currently owned by a single team. Thus, we decided to weigh the tradeoffs involved accordingly:

- ✅ Cost of development is important
- ✅ Cost of maintenance is important
- :x: Parallel test run support is **not** important


### Expected Consequences

* We **will not** be able to run multiple test runs simultaneously.

### Revisiting this Decision

If the organizational structure behind Emblem changes (for example, Emblem comes under the collective ownership of multiple different teams), we will re-evaluate this decision.

## Links

* [SJ4: Deploy a Change](https://github.com/GoogleCloudPlatform/emblem/issues/26)
* [Idempotency: `setup.sh`](https://github.com/GoogleCloudPlatform/emblem/issues/397)
* [Idempotency: Terraform](https://github.com/GoogleCloudPlatform/emblem/issues/224)
* [Decision: recycle GCP projects](/docs/decisions/2022-06-cd-pipeline-project-reuse.md)
