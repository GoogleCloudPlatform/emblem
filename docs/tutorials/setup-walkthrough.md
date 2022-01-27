# Emblem Quickstart

## Introduction

In this tutorial, you'll set up the Emblem application by following these steps:
1. Run a script to deploy Emblem to [Cloud Run](https://cloud.google.com/run)
2. Configure authentication with [OAuth 2.0 and Google Identity](https://developers.google.com/identity/protocols/oauth2)
3. Initiate continuous integration using [Cloud Build](https://cloud.google.com/build)

---

If you close this tutorial and want to come back to it, you can launch it by running the command below in the Cloud Shell terminal.  

Click the ![Copy to Cloud Shell](https://walkthroughs.googleusercontent.com/content/demo/images/copybutton.png)**Copy to Cloud Shell** button, to the right of the command, and then press `Enter`:
```bash
teachme docs/tutorials/setup-walkthrough.md
```

---

Click **Start** below to get started.

## Login
Set your application default credentials by running the command below in the terminal and logging in with your Google account:

```bash
gcloud auth application-default login
```

If you encounter auth errors, you may need to unset your `GOOGLE_APPLICATION_CREDENTIALS` in your terminal.

```bash
unset GOOGLE_APPLICATION_CREDENTIALS
``

## Set projects

Emblem uses three projects: `prod`, `stage`, and `ops`. 

You can use existing Google Cloud projects or create new projects. Choose either **Select existing projects** or **Create new projects** below and follow the instructions.

---

### Select existing projects

Emblem uses [Cloud Firestore in Native mode](https://cloud.google.com/datastore/docs/firestore-or-datastore#in_native_mode) as the database for each project. Since the selected mode is permanent for a project, make sure that your existing projects are not already using Datastore mode by checking the configuration in the [Firestore console](https://console.cloud.google.com/firestore).

Make sure that each of your projects has [billing](https://console.cloud.google.com/billing) enabled.

Set the project variables in your Cloud Shell terminal. Replace each `<prod>`, `<stage>`, and `<ops>` value with the corresponding project ID for your `prod`, `stage`, and `ops` projects.

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
---

Once you've finished setting up your projects, click **Next** to deploy Emblem.


## Run setup script

Run the following command in the terminal:
```bash
sh setup.sh
```

The script enables all necessary APIs, creates service accounts, deploys Emblem to Cloud Run, creates Cloud Build triggers,

Watch the terminal to see outputs as [Terraform](https://www.terraform.io/) builds and deploys the Emblem pipeline.

If you are prompted to enable any APIs for your projects, enter `y` in the terminal to enable them.

If you are prompted to select a region for the Cloud Run deployments, enter the number that corresponds to the region closest to your users. 

## Configure end-user authentication

The `setup.sh` script includes command line instructions to configure end-user authentication.

When you receive the prompt `"Would you like to configure end-user authentication?"`, enter `y` to proceed with the instructions.

If you choose not to configure end-user auth right now, you can always return to the command line instructions by running the [configure_auth.sh](./scripts/configure_auth.sh) script in the terminal:

```bash
sh ./scripts/configure_auth.sh
```

## Connect Cloud Build triggers

When you receive the prompt below, click the link provided and follow the instructions to connect your Emblem GitHub repository:

`Connect your repos: https://console.cloud.google.com/cloud-build/triggers/connect`

Once your repo has been connected, click **Done**, then return to the Cloud Shell terminal and press any key to continue. You will be prompted to enter the `repo owner` and `repo name`; enter the values from your repository and confirm them by pressing `y`.

## Success!

Your Emblem application is now running!

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>
<walkthrough-inline-feedback></walkthrough-inline-feedback>

### Next steps
- **Test the delivery pipeline** by pushing a change to your Emblem repo. Check out the [Cloud Build dashboard](https://console.cloud.google.com/cloud-build/builds) and inspect the build logs and tests.
