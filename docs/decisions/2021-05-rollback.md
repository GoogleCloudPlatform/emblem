# Rollback for Cloud Run uses Traffic Splitting

* **Status:** approved
* **Last Updated:** 2021-05
* **Builds on:** [Use Cloud Build for Cloud Resource management](2021-05-pipelines.md)
* **Objective:** Define "rollback" and how we implement it

## Context & Problem Statement

If we detect a problem in a deployment, we need a way to undo the deployment. The language in this space is inconsistent, so we want to use "rollback" as our baseline, but define what that means and how we'll execute it.

In the event of a bad deployment, we want to be able to revert to previous service configuration & codebase.

## Priorities & Constraints <!-- optional -->

* Get back to a running system quickly
* Minimize risk of introducing new bugs
* Managing rollbacks on data schemas or underlying infrastructure is important but lower priority.

## Considered Options

* Option 1: Redeploy a known-good container with previously used configuration
* Option 2: Route traffic to previous known-good revision

## Decision

Chosen option [Option 2]: Re-route Traffic

[Rollbacks, gradual rollouts, and traffic migration](https://cloud.google.com/run/docs/rollouts-rollbacks-traffic-migration) defines straightforward commands that can be used to redirect traffic for a service to a revision or known, mutable "tag".

This will allow a relatively easy decision to send traffic to a known working revision without the overhead or risk of rebuilding a release artifact or retrieving and reapplying configuration.

This is easy for the whole team to reason about.

### Expected Consequences <!-- optional -->

* Not all hosting platforms have this capability, which means if we choose to use other hosting platforms in the future, this rollback definition may be more complicated to implement.
* We are not addressing state, schema management, or infrastructure configuration. When we do, the traffic routing command will need to be wrapped with more complex logic.
* Service-level Cloud Run configuration such as labels will not be reverted as part of traffic routing.

## Links

* Related User Journeys
  * [Rollback a bad change](https://github.com/GoogleCloudPlatform/emblem/issues/27)
