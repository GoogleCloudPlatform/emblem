# Emblem Documentation

> This sample application is only for learning purposes.

This README is a landing page for resources that go into deeper detail about the Emblem project.

Read on if you want to explore your own Emblem instance, contribute to the project, or better understand what we've built and how it might apply to your own projects.

## Getting Started

<!-- TODO: Move documentation to ./docs -->
* [Content API](./content-api.md)
* [Website README](../website/README.md)

### Interactive Tutorials

* [API Quickstart in Cloud Shell](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/emblem&cloudshell_tutorial=docs/tutorials/api-quickstart.md)
* [Website Quickstart in Cloud Shell](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/emblem&cloudshell_tutorial=docs/tutorials/website-quickstart.md)

## API Reference Materials

<!-- TODO: Merge Example Requests with API Reference -->
<!-- TODO: Merge Example Resources with seed data -->

* [API Reference](./api-reference.md)
* [OpenAPI description](../content-api/openapi.yaml)
* [Example Requests](example_requests.md)
  * [Example Campaign Resource (Create)](resource.json)
  * [Example Campaign Resource (Update)](update_resource.json)

## Decision Log

Read the context of decisions made in this project in the [Decision Log](./decisions). Some "story arcs" within the decisions include:

* **Where to Run Your Code**: [Serverless](2021-03-serverless.md), [Cloud Run (Website)](2021-04-run-website.md), [Cloud Functions (API)](2021-04-functions-api.md), [Cloud Run (API)](2021-06-run-api.md)
* **Shipping Software**: [Using Terraform](2021-04-terraform.md) vs. [Using gcloud](2021-05-gcloud-deploy.md)
