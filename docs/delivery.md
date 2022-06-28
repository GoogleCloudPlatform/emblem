# Emblem - Delivery

![Emblem Delivery Pipeline diagram](images/testing-delivery-pipeline.png)

The Emblem delivery system is responsible for reliably shipping code changes to production.

The code lives primarily in [terraform/](https://github.com/GoogleCloudPlatform/emblem/tree/main/terraform)
and [ops/](https://github.com/GoogleCloudPlatform/emblem/tree/main/ops).

## Design

Check out the [Shipping Software decisions](docs/decisions#shipping-software) to review the delivery design as it evolved.

The installation tools & delivery system together combine to support two primary installation modes:

* *single-project*: Deploy a staging environment and delivery orchestration in a single project.
* *multi-environment*: Deploy delivery orchestration, a staging application instance, and a production application instance each in their own GCP project.

In both cases, a series of Cloud Build jobs are used to build a container, deploy a Cloud Run revision, then route traffic until rollout reaches 100%.

Pub/Sub is used to signal each step is complete, allowing the next step to operate.

### Single-project Delivery Flow

```mermaid
sequenceDiagram
  autonumber
  participant developer
  participant GitHub
  participant Cloud Build
  participant Artifact Registry
  
  developer -->> GitHub: push to main
  GitHub -->> Cloud Build: build container image
  Cloud Build -->> Artifact Registry: push image to registry
  Artifact Registry -->> Cloud Build: deploy to Cloud Run (no traffic)
  
  loop until 100%
    Cloud Build --> Cloud Build: Canary traffic rollout
  end

  Note over Cloud Build: broadcast complete rollout via Pub/Sub
```

In this sequence, all resources are in the same project as the deployed application.

### Multi-environment Delivery Flow

The multi-environment flow extends from the single-project flow. Let's look at this as a handoff between Cloud Build operations.

```mermaid
sequenceDiagram
  autonumber
  participant Staging Build (Deploy)
  participant Staging Build (Canary)
  participant Prod Build (Deploy)
  participant Prod Build (Canary)
  
  Staging Build (Deploy) --> Staging Build (Canary): ready for traffic
  Staging Build (Canary) --> Staging Build (Canary): increase traffic 
  Staging Build (Canary) --> Staging Build (Canary): increase traffic
  Staging Build (Canary) --> Staging Build (Canary): increase traffic
  Staging Build (Canary) --> Prod Build (Deploy): staging at 100% rollout
  Note over Prod Build (Deploy): deploy to Cloud Run (no traffic)

  Prod Build (Deploy) --> Prod Build (Canary): ready for traffic
  Prod Build (Canary) --> Prod Build (Canary): increase traffic 
  Prod Build (Canary) --> Prod Build (Canary): increase traffic 
  Prod Build (Canary) --> Prod Build (Canary): increase traffic 
  Note over Prod Build (Canary): broadcast complete rollout via Pub/Sub
```

In this sequence, Cloud Build and Artifact Registry are in an "ops" project, Staging is in a staging project, and Production is in a prod project.
