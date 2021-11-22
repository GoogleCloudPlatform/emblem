# Prefer Serverless Platforms for Application Hosting

* **Status:** approved
* **Last Updated:** 2021-03
* **Objective:** Determine a preferred approach to application hosting.

## Context & Problem Statement

We expect to host multiple services/apps on Google Cloud. Each should use the right platform for the job, but often there are multiple right answers.

We wish to choose a default platform ecosystem" where the developer experience tradeoffs are consistent, the skills our team needs to be successful are understood, and platform knowledge can expedite design & communications.

## Priorities & Constraints <!-- optional -->

* Limit infrastructure management
* Limit cost during R&D
* We anticipate bursty traffic
* We anticipate mostly transactional web services or background operations

## Considered Options

* Option 1: Compute Engine
* Option 2: Kubernetes Engine
* Option 3: Serverless (Run, Functions, App Engine)

## Decision

Chosen option [Option 3: Serverless]

We have chosen to default our practice to the Serverless ecosystem.

It provides strong developer experience, limited infrastructure management, and the biggest concerns (e.g., cold start latency) are things we feel are acceptable for the sorts of seasonal/internal workloads we expect to run.

Our team of mostly application developers is comfortable working with Serverless platforms.

### Expected Consequences <!-- optional -->

Workloads that do not fit into a Serverless form will need to be hosted in a platform/ecosystem less familiar to the team.
