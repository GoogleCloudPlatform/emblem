# Decision Log

In this project we capture important decisions with [architectural decision records](https://adr.github.io/).

These records provide context, trade-offs, and reasoning taken at our community & technical cross-roads. Our goal is to preserve the understanding of how the project has grown, and capture enough insight to effectively revisit previous decisions.

Get started created a new decision record with the template:

```sh
cp template.md NN-title-with-dashes.md
```

## Team Structure

[Conway's Law](https://en.wikipedia.org/wiki/Conway%27s_law)
posits that software design is a function of organizational design. Emblem was
developed by a group of core contributors working on a single team within a 
large software company (Google), with supporting contributions from members of
other teams both internal and external to the company.

While we've done our best to make Emblem applicable to a wide variety of
organizational structures, Emblem may require some adaptation to properly
account for aspects unique to your organization.

## Evolving Decisions

Many decisions build on each other, a driver of iterative change and messiness
in software. By laying out the "story arc" of a particular system within the
application, we hope future maintainers will be able to identify how to rewind
decisions when refactoring the application becomes necessary.

Here are a few story arcs of decisions made in the project.

### Where to Run Your Code

Step through our decisions that led to hosting on Cloud Run.

* [Serverless](2021-03-serverless.md)
* [Cloud Run (Website)](2021-04-run-website.md)
* [Cloud Functions (API)](2021-04-functions-api.md)
* [Switch to Cloud Run (API)](2021-06-run-api.md)

### Shipping Software

We have a hybrid model of terraform for infrastructure, gcloud & continuous delivery
for shipping code, and additional decisions on how we handle the necessary automation
and orchestration.

* [Using Terraform](2021-04-terraform.md) vs. [Using gcloud](2021-05-gcloud-deploy.md)
* [Use Cloud Build to manage resources](2021-05-pipelines.md)
* [Canary Rollouts](2021-04-cloud-build.md)
* [How to Rollback](2021-05-rollback.md)
* [Manage Ops resources via a central project](2021-04-ops-project.md)
* [Automate dependency updates](2022-06-automate-dependencies.md)

### End-user Authentication

Getting end-user authentication right was a challenge. The current implementation
extends from the write-up in [Auth Design](../auth-design.md). There were several
decisions and reversals to reach it.

* [Use Cloud Identity Platform for SSO](2021-07-cloud-identity.md)
* [User & Application Authorization](2021-07-user-app-auth.md)
* [Session Cookies](2021-08-13-session-cookies.md)
* [Refreshing ID Token](2021-11-refreshing-id-tokens.md)
* [New approach to user authentication](2021-11-user-authentication.md)
* [Use backend session storage, starting with Cloud Storage](2021-10-session-data-storage.md) (benchmarking needed!)
* [Refreshing identity tokens](2021-11-refreshing-id-tokens.md)
* [Storing OAuth Secrets](2021-12-storing-oauth-config-secrets.md)
