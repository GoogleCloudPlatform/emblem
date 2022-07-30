# Allow programmatic IAM policy provisioning with role restrictions

* **Status:** approved
* **Last Updated:** 2022-08
* **Objective:** Clarify how tests should manage Terraform-managed IAM privileges

## Context & Problem Statement

Programmatic Emblem deploys are necessary in order for us to write [automated tests for the Delivery component](/docs/testing.md#pipelines--delivery-system).

Programmatically provisioning most Emblem resources is straightforward - since Emblem uses [Terraform](https://terraform.io) for infrastructure management, this can be as simple as running `terraform apply`.

IAM policies are an exception to this rule. Allowing programmatic IAM policy changes is genuinely dangerous, as automated accounts with permissions to modify IAM policies can easily [escalate their own privileges](https://en.wikipedia.org/wiki/Privilege_escalation).

## Priorities & Constraints

* **Programmatic deploys** are required to properly test Emblem.
* Emblem's Terraform configuration declares several **IAM policies**.
  * These policies are **required** to run the Emblem application, and cannot be opted-out of.
* Emblem's IAM policies must be **explicitly provisioned** within Google Cloud projects.

## Considered Options

### Option 1: Singleton IAM Policies

We could create Emblem's IAM policies manually.

To prevent state conflicts within Terraform, we could manually manage IAM policy state. This is done using `terraform import` and `terraform state rm` to _find_ and _forget_ the existing IAM policies respectively.

### Option 2: Programmatically-provisioned IAM Policies

We could also allow accounts performing programmatic Terraform provisioning runs to manage IAM policies themselves.

These accounts - and Terraform itself - would then be responsible for orchestrating IAM state changes.

## Decision

We chose to use **Programmatically-provisioned IAM Policies**, coupled with [restrictions on which roles could be programmatically granted](https://cloud.google.com/iam/docs/setting-limits-on-granting-roles#writing-condition).

✅ This approach enables our team to minimize the amount of state we have to manage outside Terraform.

❌ This approach slightly increases the security risk in the event that an automated account/process is compromised.

## Links

* Related PRs
    * [Document Roles in CI Pipeline](https://github.com/GoogleCloudPlatform/emblem/pull/489)
* Related User Journeys
    * [Limit Blast Radius of a Security Exploit](https://github.com/GoogleCloudPlatform/emblem/issues/45)
