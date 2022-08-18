# Prefer ephemeral end-to-end test fixtures where possible

* **Status:** approved
* **Last Updated:** 2022-07
* **Objective:** Clarify the use of permanent vs. reusable Cloud resources

## Context & Problem Statement

Emblem evolved to use long-lived, singleton test fixtures in end-to-end (E2E) test runs. These include resources such as Google Cloud projects, Cloud Storage buckets, container images in Artifact Registry, and Cloud Run services.

We decided to investigate whether we should migrate these long-lived, singleton fixtures to a more ephemeral approach.

## Priorities

Ideally, our end-to-end test fixtures would be designed such that:

* Test infrastructure is quick to set up.
* Test infrastructure is documented (e.g. via Terraform files).
* Tests themselves are quick to write.
* Both tests and their infrastructure require minimal maintenance.
* Tests are runnable by multiple [teams of] developers in parallel.
* Tests cover as much of the application surface as possible.
* Tests allow developers and contributors to quickly identify root causes of bugs.
* Tests have minimal reliance on existing state.

Of course, some of these goals are mutually exclusive: supporting parallel end-to-end test runs often increases the cost of writing (and in some cases maintaining) those tests and test infrastructure.

## Constraints

### Some resources **must** be singletons
While most of Emblem's Google Cloud resources are provisioned programmatically using Terraform, some (such as the Google Cloud projects themselves^) are currently intended to be provisioned manually.

> ^ This is due to organization-wide IT security concerns about programmatic project creation that our team must abide by.

Consequently, we can't rely entirely on automated provisioning systems (at least, not without significant further engineering and/or documentation work) to spin the entire project up and down arbitrarily.

### Emblem is owned by a single team
While Emblem is designed with a service-oriented architecture, all of Emblem's components are (currently) owned by the same team.

> Consequently, optimizing our end-to-end test fixtures for multi-team collaboration (such as large numbers of parallel end-to-end test runs) isn't as important as minimizing test development/maintenance costs.

## Considered Options

In this case, we have a _continuous spectrum_ of options. Thus, the "options" below are more _extremes_ than options:

* **Extreme 1:** All end-to-end fixtures are centralized, long-lived singletons. Under no circumstances should 2+ instances of the same fixture exist.
* **Extreme 2:** All end-to-end fixtures are ephemeral and short-lived, and pluralistic (multiple instances can simultaneously coexist). 

## Decision

We'll use _programmatically provisioned_ fixture resources wherever practical. These resources can be made ephemeral and/or pluralistic (via tools like the [cleanup script](installation-testing/terraform/cleanup.sh)) if necessary.

Examples include:

- Cloud Run services
- Cloud Storage buckets
- Service Accounts
- IAM policies
- Artifact Registry repositories

In some situations, _manual provisioning_ of centralized resources will be simpler to implement (if not outright required). Usually, these resources **cannot** be made ephemeral and must be reused between end-to-end test runs.

Examples include:

- Google Cloud projects
- Cloud Firestore environments _(these are tied to Google Cloud projects)_

### Rationale

The entire Emblem application is currently owned by a single team. Thus, we decided to weigh the tradeoffs involved accordingly:

- ✅ Cost of development is **more** important
- ✅ Cost of maintenance is **more** important
- :x: Support for parallel end-to-end test runs is **less** important.

### Expected Consequences

* We **will not** be able to run multiple end-to-end test runs simultaneously.

### Revisiting this Decision

Currently, the ongoing cost of maintaining long-lived resources is very low. Even though "pluralizing" these resources is an {eminently justifiable && one-time} cost, this pluralization effort is not currently a high priority.

This may change for one of two reasons:

#### Team Structure Changes
The Emblem team's underlying organizational structure changes. (For example, Emblem may transform from single-team project to one collectively owned by multiple different teams. Each team [member] would likely want end-to-end testing fixtures dedicated specifically for them, which would be easier to achieve with a more pluralistic approach.)

#### Roadmap Progress
If the Emblem team executes quickly on the project's roadmap (enough to outrun any scope creep), Emblem's "most important" priorities will gradually become less important over time.

Given time, test pluralization may rise to the top of our prioritized worklog. If such a scenario occurs, we will of course revise this decision.

## Links

* [SJ4: Deploy a Change](https://github.com/GoogleCloudPlatform/emblem/issues/26)
* [Idempotency: `setup.sh`](https://github.com/GoogleCloudPlatform/emblem/issues/397)
* [Idempotency: Terraform](https://github.com/GoogleCloudPlatform/emblem/issues/224)
* [Decision: recycle GCP projects](/docs/decisions/2022-06-cd-pipeline-project-reuse.md)
