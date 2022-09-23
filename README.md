# 💠 Emblem Giving
---
## 🚧 THIS PROJECT IS IN ALPHA STAGE 🏗️
---

Emblem Giving is a sample application intended to demonstrate a complex, end-to-end serverless architecture. It showcases serverless continuous delivery as a donation sample app hosted on Google Cloud.   

> This sample application for learning purposes only. Real financial transactions are not made. The giving campaigns in the app are not real.

## Features

This project features:
  * 2-tier web application architecture with Cloud Run
  * continuous delivery with Cloud Build
  * Terraform deployment
  * Example configuration and usage of the following Google services and apis:
    * Cloud Run
    * IAM
    * Secret Manager
    * Cloud Storage
    * Cloud Firestore
    * Cloud Build
    * Artifact Registry
    * Pub/Sub


Go deeper into project details in the [documentation](./docs) or read through the [technical decisions](docs/decisions/README.md) that got us where we are today.

## Service architecture

![Emblem architecture diagram](./docs/images/emblem-simplified.png)

## Project Status

* **Release Stage:** Alpha
* **Self-service / Independent Setup:** Follow the instructions to set up Emblem by reading the [setup quickstart](./docs/tutorials/setup-quickstart.md), or by launching the [Interactive Walkthrough](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https%3A%2F%2Fgithub.com%2FGoogleCloudPlatform%2Femblem&cloudshell_tutorial=docs%2Ftutorials%2Fsetup-walkthrough.md) on Cloud Shell.

## Contributing

* Become a [CONTRIBUTOR](./CONTRIBUTING.md)!
* Check out our shovel-ready [Good First Issues](https://github.com/GoogleCloudPlatform/emblem/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc+label%3A%22good+first+issue%22) or go a bit deeper in [Help Wanted](https://github.com/GoogleCloudPlatform/emblem/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc+label%3A%22help+wanted%22)

## Getting Started

Emblem is made of a combination of resources created and managed by Terraform and resources created via the Google Cloud CLI or Google Cloud Console. You may deploy Emblem by either running `setup.sh` (see [streamlined setup instructions](#streamlined-setup)) or by following the [manual steps below](#manual-setup). 

### Prerequisites

To deploy Emblem, you will need 3 Google Cloud projects (ops, stage, prod) with billing enabled on each.  

Your local host will need the following installed:
* Google Cloud CLI
* Terraform
* Python3

We recommend running through setup steps using Google Cloud Shell, which has the required softare pre-installed. The following will open Cloud Shell Editor and clone this repo:

 [![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https%3A%2F%2Fgithub.com%2FGoogleCloudPlatform%2Femblem&cloudshell_tutorial=docs%2Ftutorials%2Fsetup-walkthrough.md)

### Streamlined setup

```

```

### Manual setup

```

```

---

This is not an official Google project.
