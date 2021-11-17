# Host Content API on Cloud Functions

* **Status:** superceded by [2021-06 API on Cloud Run](2021-06-run-api.md)
* **Last Updated:** 2021-04
* **Builds on:** [Prefer Serverless](2021-03-serverless.md), [Python Default](2021-03-python-backend.md)
* **Objective:** Choose a serverless hosting platform for the Content API

## Context & Problem Statement

We are building a REST-style API to broker all key CRUD & business logic, transactions, and data access rules. It will be built in Python, based the [previous decision to default to Python](2021-03-python-backend.md) as the common application development language on the team.

Where should we run an API implemented in Python?

## Priorities & Constraints <!-- optional -->

* Expecting strong separation of data for different resources
* Expecting to serve JSON resources, sometimes filtered based on user identity

## Considered Options

* Option 1: Cloud Run
* Option 2: Cloud Functions

## Decision

Chosen option [Option 2: Cloud Functions]

Cloud Functions would allow each operation to be created as a small, standalone function. This will make it easier to spread implementation work across multiple developers.

Each deployed function will independently scale, and access control, monitoring, and business metrics around API operations can align to how we manage and monitoring individual Cloud Functions.

With a more conventional approach using Cloud Run, we'll need to resource the service for all REST resources at once, and pay to scale up those resources when most of the traffic is for lighter-weight read operations.

### Expected Consequences <!-- optional -->

* More complicated build pipeline
* Embracing a "FaaS" approach to building an API requires learning new approaches on implementing API design, local development. We're not working one resource at a time but one use case at a time.

### Revisiting this Decision <!-- optional -->

We're making a decision to try a new approach. We'll need to watch the efficiency of this approach while accounting for the learning curve.

## Links

Related: [Host Website on Cloud Run](2021-04-run-website.md)
