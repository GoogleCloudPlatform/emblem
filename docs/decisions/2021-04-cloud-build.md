# Canary Rollouts for Continuous Delivery Pipeline

* **Status:** approved
* **Last Updated:** 2022-02-04
* **Objective:** Create a safe continuous rollout system using generally available Cloud Run and Cloud Build features.

## Context & Problem Statement

[DORA](https://www.devops-research.com/research.html) research shows that using continuous delivery improves all four delivery metrics: deployment frequency, lead time for change, change failure rate, and time to restore.  Many developers see velocity and stability as mutually exclusive.  However, the research shows that if you set up your rollout system with an eye for continuous delivery, you can have both!  

In order to achieve this, we need a way to automatically deploy and rollout our application that is both low-risk and low-latency.  

## Priorities & Constraints <!-- optional -->

* There should be no downtime in deployment
If a bug is introduced, it should affect the smallest possible group of end-users. (Ideally, nobody.)

## Considered Options

### All-At-Once Deployment

This option is simple and fast.  However, if we deploy our new revisions directly to 100% traffic, there is a higher risk of bugs being introduced into the production environment, with a larger impact on our users.  If we had planned outages, this could be a viable option.

### Blue-Green Deployment

A blue-green deployment strategy uses two services, one is "blue" (staging) and one is "green" (prod). Once the blue service is deemed safe and stable, user traffic is shifted to that service.  This is lower risk than the Basic Deployment strategy, but a shift of 100% traffic in one lump still carries significant risk.  For instance, users in different regions may experience your service differently, which would not be visible until the traffic swap. At that point, you have an instance which has affected a large number of users and needs to be reverted.

It can also be very complex and expensive to replicate a full production environment. While we manage our infrastructure with `Terraform`, one cannot ever be certain that all resources are ready for traffic, or that all environment variables are updated, etc.  

Thankfully, the question of cost is largely mitigated by the Serverless scale-to-zero cost model.

### Canary Rollouts

In a canary rollout, a new deployment is created and the traffic is incrementally increased in small chunks. It is the least risky, because if a bug is found in production, the rollout can be stopped and the traffic reverted for the small number of users affected.  Furthermore, it does not require maintaining two full production environments.  

The downside is that canary rollout systems are almost always complex and difficult to automate.  

## Decision

We decided to use canary rollouts, as they carry the least risk. Furthermore, implementing canary rollouts allows us to better understand our users who want to use the same strategy but do not have a good system to manage it.  

The handmade pipeline we've created uses Cloud Build, Pub/Sub, and the Cloud Run traffic management feature.  It automatically deploys to `staging` and requires a manual approval for deployment to `prod`.  Lastly, users may adjust the traffic increments to both the `staging` environment and `prod`.  

In the future, we hope to migrate to a managed deployment system, which will allow us to more easily visualize our pipeline and manage our rollouts.  We will use this opportunity to show our users our migration story from a handbuilt deployment system to a managed deployment product.

## Design elements

Our canary rollout system uses Cloud Build to recursively increase traffic until we hit 100%.  This approach allows us to maintain a DRY style of code, thus helping reduce tech debt and ensure maintainability.  Furthermore, it means the user can adjust the traffic jumps, because each increase is `current_traffic` + `N`.  The alternative is to write each traffic increase explicitly, which hardcodes in the values and increases the chance of the commands getting out of sync over time.  

We are using Cloud Build because it is the main Google Cloud Platform CI/CD tool.  This allows us to take advantage of the security benefits of the Cloud Build identity and other integrations (eg Secret Manager).  

## Links

* Related User Journeys
  * https://github.com/GoogleCloudPlatform/emblem/issues/26
