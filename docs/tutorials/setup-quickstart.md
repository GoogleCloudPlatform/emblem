# Emblem Quickstart

## Introduction

This tutorial shows you how to run a setup script to deploy the Emblem application to [Cloud Run](https://cloud.google.com/run), configure authentication with with [OAuth 2.0 and Google Identity](https://developers.google.com/identity/protocols/oauth2), and initiate continuous integration using [Cloud Build](https://cloud.google.com/build).

## Environment setup

To clone Emblem into a preconfigured Cloud Shell instance and launch the setup instructions as an interactive tutorial, click the button under [Open in Cloud Shell](#open-in-cloud-shell). Otherwise, configure your machine by following the instructions under [Configure environment](#configure-environment).

---
### Open in Cloud Shell

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https%3A%2F%2Fgithub.com%2FGoogleCloudPlatform%2Femblem&cloudshell_tutorial=docs%2Ftutorials%2Fsetup-walkthrough.md)


---
### Configure environment

1. Ensure that the following dependencies are installed on your machine:
* Python (3.8 or higher)
* [pip](https://pypi.org/project/pip/)
* [git](https://github.com)
* [Cloud SDK](https://cloud.google.com/sdk/docs/install)

2. Clone the Emblem application and cd into the `emblem` directory by running the command below in your terminal:
  ```bash
  git clone https://github.com/GoogleCloudPlatform/emblem.git
  cd emblem
  ```


## Login
Set your application default credentials by running the command below in the terminal and logging in with your Google account:

```bash
gcloud auth application-default login
```

If you encounter auth errors, you may need to unset your `GOOGLE_APPLICATION_CREDENTIALS` in your terminal.

```bash
unset GOOGLE_APPLICATION_CREDENTIALS
```

## Set projects

Emblem uses three projects: `prod`, `stage`, and `ops`. 

You can use existing Google Cloud projects or create new projects. Choose either **[Select existing projects](#select-existing-projects)** or **[Create new projects](create-new-projects)** below and follow the instructions.

---

### Select existing projects

Emblem uses [Cloud Firestore in Native mode](https://cloud.google.com/datastore/docs/firestore-or-datastore#in_native_mode) as the database for each project. Since the selected mode is permanent for a project, make sure that your existing projects are not already using Datastore mode by checking the configuration in the [Firestore console](https://console.cloud.google.com/firestore).


1. Set the project variables in your terminal. Replace each `<prod>`, `<stage>`, and `<ops>` value with the corresponding project ID for your `prod`, `stage`, and `ops` projects.

  ```bash
  export PROD_PROJECT=<prod>
  ```
  ```bash
  export STAGE_PROJECT=<stage>
  ```
  ```bash
  export OPS_PROJECT=<ops>
  ```

---

### Create new projects

1. Copy the commands below into your terminal to create new `prod`, `stage`, and `ops` projects.
  ```bash
  export PREFIX=$(gcloud config get-value account | cut -f1 -d"@")-emblem
  export PROD_PROJECT=$PREFIX-prod
  export STAGE_PROJECT=$PREFIX-stage
  export OPS_PROJECT=$PREFIX-ops

  gcloud projects create $PROD_PROJECT
  gcloud projects create $STAGE_PROJECT
  gcloud projects create $OPS_PROJECT
  ```
2. Set your billing account. (You can view your existing billing accounts by running `gcloud alpha billing accounts list` in the terminal.)
  ```bash
  export BILLING_ACCOUNT_NAME="My Billing Account"
  export EMBLEM_BILLING_ACCOUNT=$(gcloud alpha billing accounts list --filter "$BILLING_ACCOUNT_NAME" --format "value(name)")
  ```

3. Link the newly created projects to your billing account:
  ```bash
  gcloud alpha billing projects link $PROD_PROJECT --billing-account $EMBLEM_BILLING_ACCOUNT
  gcloud alpha billing projects link $STAGE_PROJECT --billing-account $EMBLEM_BILLING_ACCOUNT
  gcloud alpha billing projects link $OPS_PROJECT --billing-account $EMBLEM_BILLING_ACCOUNT
  ```  

## Run setup script

Run the following command in the terminal:
```bash
sh setup.sh
```

The script enables all necessary APIs, creates service accounts, deploys Emblem to Cloud Run, and initiates the creation of Cloud Build triggers for continuous integration.

Watch the terminal as [Terraform](https://terraform.io) builds and deploys the Emblem pipeline.

If you are prompted to enable any APIs for your projects, enter "y" in the terminal to enable them.

If you are prompted to select a region for the Cloud Run deployments, enter the number of the region closest to your users. 

## Configure end-user authentication

The `setup.sh` script includes command line instructions to configure end-user authentication.

When you receive the prompt `"Would you like to configure end-user authentication?"`, enter `y` to proceed with the instructions.

If you choose not to configure end-user auth right now, you can always return to the command line instructions by running the [configure_auth.sh](./scripts/configure_auth.sh) script in the terminal:

```bash
sh ./scripts/configure_auth.sh
```

## Connect Cloud Build triggers

When you receive the prompt below:
`Connect your repos: https://console.cloud.google.com/cloud-build/triggers/connect`

Click the link provided in the prompt and follow the instructions to connect your repository. 

Once your repo has been connected, click **Done**, then return to the terminal and press any key to continue. You will be prompted to enter the `repo owner` and `repo name`; enter the values from your repository and confirm them by pressing `y`.

## Success

Your Emblem application is now running!

### Next steps
Test the delivery pipeline by pushing a change to your Emblem repo. Check out the [Cloud Build dashboard](https://console.cloud.google.com/cloud-build/builds) and inspect the build logs and tests.
