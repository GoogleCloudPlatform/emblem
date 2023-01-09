# Using a Cloud Build Alpha for Pub/Sub triggers

* **Status:** approved
* **Last Updated:** 2021-07
* **Builds on:** [Canary Rollouts for Continuous Delivery Pipeline](2021-04-cloud-build.md), [Use Cloud Build for Cloud Resource management](2021-05-pipelines.md)

In order to handle cross-project triggers and canary rollouts, we are using the **alpha Cloud Build Pub/Sub triggers**.

For the canary rollouts, this decision was reached mainly because it is the only Cloud Build trigger type that can gracefully handle gradually increasing traffic on a deployment.  Alternatively, we could manage rollouts via:

 - A **Cloud Function**
 - A shell script
 - One very long explicit Cloud Build config

The Pub/Sub triggers are simpler, do not require any extra code to manage, and are DRY-er than having one long `cloudbuild.yaml` which repeats each step with slightly higher traffic percentages.  Ultimately, we will migrate to **Cloud Deploy**, which should manage rollouts for us.  As it is not yet available for Cloud Run, Pub/Sub triggers are our best option.

For cross-project triggers, Pub/Sub triggers allow us to limit the permissions granted to the Cloud Build service account in the source project.  If we handled all cross-project deployments this way, the service account would only need to have the Pub/Sub Publisher role in the 2nd project.
