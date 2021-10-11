# Deploy code with gcloud

* **Status:** approved
* **Last Updated:** 2021-05
* **Builds on:** [Use Terraform for Infrastructure Management](2021-04-terraform.md)
* **Objective:** Determine how to deploy services

## Context & Problem Statement

We have previously chosen to use terraform for infrastructure management. Terraform is not a CI/CD tool and is not well suited for code deployment.Serverless services are an interesting case, in how they blend some aspects of infrastructure with code.

## Priorities & Constraints <!-- optional -->

* Balance an effective hands-on experience for developers with formal resource management.
* Serverless services include both code and infrastructure changes

## Considered Options

1. Terraform
1. gcloud
1. gcloud + Cloud Run service.yaml

## Decision

Chosen option: "[option 2] gloud".

* Keep infrastructure and software management separate, changing software doesn't necessarily disrupt infrastructure
* Keep deployment operations familiar and help developers derive their own gcloud commands for research & troubleshooting

### Expected Consequences <!-- optional -->

* We are not applying an auditable, infrastructure-as-code approach to Serverless service infrastructure
* New instance setup will require both Terraform & gcloud steps
* Infrastructure that depends on Service deployment will require a separate terraform process

## Links

* https://github.com/GoogleCloudPlatform/issues/25
* https://github.com/GoogleCloudPlatform/issues/26
* https://github.com/GoogleCloudPlatform/issues/27
* https://github.com/GoogleCloudPlatform/issues/44
