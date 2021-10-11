# Use Terraform in a Single Directory

* **Status:** approved
* **Last Updated:** 2021-05
* **Builds on:** [Use Terraform for Infrastructure Management](2021-04-terraform.md), [Monorepo for Code Management](2021-05-monorepo.md)
* **Objective:** Determine if Terraform should be centralized or decentralized

## Context & Problem Statement

Terraform for a project generally lives in a `terraform/` directory. However, our repository includes multiple components as standalone services. Should infrastructure ownership be standalone, or should each service own it's own dependencies?

## Priorities & Constraints <!-- optional -->

* Delivery across the project has a single lead
* Dependencies are more easily managed with a centralized terraform definition

## Considered Options

1. **Terraform at `/terraform`**: Terraform is contained in a single directory
1. **Terraform per Component**: Each component (website, content-api, and delivery) has independent terraform definition & state
1. **Terraform Controller & Modules per Component**: Terraform has centralized resources at `/terraform` and each component supplies it's own module. Each component may optionally provide it's own terraform entrypoint to be independently tested.

## Decision

Chosen option: "[option 1] Terraform at `/terraform`".

With a single engineer overseeing responsible for terraform excellence and knowledge unevenly spread across the team, we want to avoid "premature optimization" of the components.

### Expected Consequences <!-- optional -->

* We have an "infrastructure monolith"
* The infrastructure monolith further risks us falling into the "distributed monolith" anti-pattern for the application
* As an example terraform implementation, we will be less effective at showing how service teams can own their own infrastructure

### Research

* https://www.terraform.io/docs/language/modules/develop/composition.html
* https://opencredo.com/blogs/terraform-infrastructure-design-patterns/
* https://www.hashicorp.com/resources/evolving-infrastructure-terraform-opencredo

## Links

* **User Journey:** https://github.com/GoogleCloudPlatform/emblem/issues/25
