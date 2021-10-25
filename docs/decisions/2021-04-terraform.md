# Use Terraform for Infrastructure Management

* **Status:** approved
* **Last Updated:** 2021-04
* **Objective:** Decide how we will create & manage Cloud resources

## Context & Problem Statement

We need a repeatable &  auditable approach to managing infrastructure.

## Priorities & Constraints <!-- optional -->

* Maximize automation for maintenance overhead

## Considered Options

* Commands copied from READMEs
* Shell scripts & gcloud
* Terraform

## Decision

Chosen option: Terraform

Terraform is a leading tool for Infrastructure as Code and provides support for automation, auditing, enforcement, and is supported with comprehensive integration across Google Cloud.

### Expected Consequences <!-- optional -->

* Not all practitioners are familiar with Terraform. However, we believe Infrastructure-as-Code should be a pervasive practice.
* We want required infrastructure to be defined as part of the PR which introduces the need. However, this will need more frequent exceptions as contributors are less likely to be familiar with Terraform.

## Links

* **User Journey:** https://github.com/GoogleCloudPlatform/emblem/issues/25
