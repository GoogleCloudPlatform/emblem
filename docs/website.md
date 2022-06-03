# Emblem - Website

![Emblem Application architecture diagram](../docs/images/application.png)

The Emblem Website code lives in its own [directory](https://github.com/GoogleCloudPlatform/emblem/tree/main/website).

## Design

The Emblem Website is configured as a [Cloud Run](https://cloud.google.com/run) service written using the [Flask](https://flask.palletsprojects.com/en/2.0.x/) web framework for Python.

The website uses the following Google Cloud services:

* **Google Identity** - handles user sign-in and authentication
* **Secret Manager** - manages OAuth client secrets
* **Cloud Storage** - stores session data

Emblem uses a testing & delivery pipeline to automate deployment of the web application (Website & Content API) and setup of operations management.

To deploy the Emblem Website manually, either launch the [Quickstart](#quickstart) interactive tutorial or follow the [Setup](#setup) guide below.

## Interactive Walkthrough for Setup

Learn how to run the website by following an interactive tutorial on Cloud Shell, a free browser-based IDE that comes preconfigured with the necessary tools to run Emblem. Click the button below to clone Emblem into a Cloud Shell instance and launch the interactive tutorial:

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https%3A%2F%2Fgithub.com%2FGoogleCloudPlatform%2Femblem&cloudshell_tutorial=docs%2Ftutorials%2Fwebsite-quickstart.md)

> Note: some elements of the website will not function without a deployed instance of the Emblem Content API. Learn how to run the Content API by launching the [API Quickstart on Cloud Shell](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https%3A%2F%2Fgithub.com%2FGoogleCloudPlatform%2Femblem&cloudshell_tutorial=docs%2Ftutorials%2Fapi-quickstart.md).

## Manual Instructions for Setup

### Deploy the website container to Cloud Run

1. Navigate to the directory `website/`.

1. Copy the `client-libs/` directory located in root folder

    ```sh
    cp -rf ../client-libs/ .
    ```

1. Create an environment variable that contains your API server url and your Emblem session bucket name.

    ```sh
    export SITE_VARS="EMBLEM_API_URL=$EMBLEM_API_URL, EMBLEM_SESSION_BUCKET=$EMBLEM_SESSION_BUCKET"
    ```

1. Build an image with Cloud Build

    ```sh
    gcloud builds submit . --tag=gcr.io/$PROJECT_ID/website
    ```

1. Deploy to Cloud Run

    ```sh
    gcloud run deploy \
      --image=gcr.io/$PROJECT_ID/website \
      --set-env-vars "$SITE_VARS" website
    ```

Navigate to the URI provided upon successful deployment.

### Setting up authentication

> **Note:** end-user authentication is required to access some - _but not all_ - application pages.

To enable end-user authentication within the application, you'll need to create an [OAuth client ID](https://console.cloud.google.com/apis/credentials/oauthclient) and configure an [OAuth consent screen](https://console.cloud.google.com/apis/credentials/consent).

If you don't already have an OAuth client set up, you can run the Emblem [configure_auth](./scripts/configure_auth.sh) script in your terminal:

```sh
sh ./scripts/configure_auth.sh
```

### Configuration

To configure the app, set the following environment variables:

| **Variable name**       | **Description**                                           |
| ----------------------- | --------------------------------------------------------- |
| `CLIENT_ID`             | The client ID of your OAuth 2.0 client.               |
| `CLIENT_SECRET`         | The client secret of your OAuth 2.0 client.           |
| `REDIRECT_URI`          | A redirect_uri authorized for your OAuth 2.0 client   |
| `EMBLEM_API_URL`        | A URL pointing to your instance of the Emblem Content API |
| `EMBLEM_SESSION_BUCKET` | The name of your [Cloud Storage bucket](https://cloud.google.com/storage/docs/key-terms#buckets). |

The `CLIENT_ID` and `CLIENT_SECRET` can be found in the details page of your [Credentials dashboard](https://console.cloud.google.com/apis/credentials).

> **Note: these are sensitive values that should be kept secure.** When deployed with the production pipeline, Emblem uses Secret Manager to store these values more securely.

The `EMBLEM_API_URL` value will be determined by where you host the Content API. (If you're using Cloud Run, it will look something like `https://<SERVICE_NAME>-<HASH>.run.app`)

Congratulations! You are now ready to run the Emblem web app.

## Running Locally

### Downloading tools

To run this project, you'll need the following tools:

* Python (3.9 or higher)
* [pip](https://pypi.org/project/pip/)

The following tools are optional, but recommended:

* [pyenv](https://github.com/pyenv/pyenv)

### Installing dependencies

To install dependencies for the website, `cd` into the `website` directory and
run `pip install -r requirements.txt`.

### Manual Setup

Complete the steps as documented above:

1. Navigate to the directory `website/`.

1. Copy the `client-libs/` directory located in root folder

    ```sh
    cp -rf ../client-libs/ .
    ```

1. Set up the [Cloud-based identity provider for your local app](#setting-up-authentication)

1. [Configure the service via environment variables](#configuration)

### Running

Use the `flask run` to run the website locally.

By default, the website will run on port `8080`.

### Seeding the Database

If your site is missing default content, see the [Content API instructions to
seed the database](./content-api.md#seed-database).
