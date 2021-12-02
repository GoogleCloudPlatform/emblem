# Run the Emblem Giving Website locally on Cloud Shell
##
This tutorial shows you how to quickly run the Emblem Giving Website with Flask. You'll use Cloud Shell, a free browser-based IDE.

The Website requires a deployed instance of the Emblem Giving API in order to function properly. You can deploy the Content API on Cloud Shell by following the [API Quickstart Tutorial](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/emblem&cloudshell_git_branch=main&cloudshell_tutorial=docs/tutorials/api-quickstart.md).

For the best experience, launch this tutorial as an interactive walkthrough on Cloud Shell: [Open in Cloud Shell](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/emblem&cloudshell_git_branch=main&cloudshell_tutorial=docs/tutorials/website-quickstart.md).

Let's get started!

## Set working directory

Clicking the **Open in Cloud Shell** link automatically clones the Emblem Giving GitHub repo to your Cloud Shell instance.

Open the `website` folder as your current working directory in the Cloud Shell terminal:
```bash
cd website
```

## Set GCP project
In order to run the Website, you'll need to use a new or existing [Google Cloud Platform project](https://cloud.google.com/resource-manager/docs/creating-managing-projects).

<walkthrough-project-setup></walkthrough-project-setup>

If prompted, authorize Cloud Shell to make GCP API calls.


## Create a Cloud Storage bucket

The Website's session data is stored in a Cloud Storage bucket. You'll want to create a new bucket to ensure that the Website data doesn't conflict with any existing data in a bucket.

Create a Cloud Storage bucket and set the `EMBLEM_SESSION_BUCKET` variable:
```bash
  gsutil mb -p {{project-id}} gs://{{project-id}}-emblem-session
  export EMBLEM_SESSION_BUCKET={{project-id}}-emblem-session
```

## Set client credentials

Emblem Giving uses [Google Identity](https://developers.google.com/identity) to manage authentication.

Find your OAuth 2.0 credentials and set them as environment variables in Cloud Shell:

1. Go to the [Credentials](https://console.developers.google.com/apis/credentials) page.

2. Click the name of your credential or the pencil (<walkthrough-cloud-shell-editor-icon></walkthrough-cloud-shell-editor>) icon. Your client ID and secret are at the top of the page.

In the Cloud Shell terminal, set your `CLIENT_ID` and `CLIENT_SECRET` as environment variables:
```bash
export CLIENT_ID=<client-id>
```
```bash
export CLIENT_SECRET=<client-secret>
```

Once you have finished setting up your credentials in Cloud Shell, click **Next**.


## Run the Website

Now you can run and preview the Website.

1. Set the value of `EMBLEM_API_URL` as the URL for your running instance of the Emblem Content API:
```bash
export EMBLEM_API_URL=http://localhost:8080
```

2. Install the application dependencies:
```bash
pip3 install -r requirements.txt
```

3. Run the Website using Flask:
```bash
flask run
```

Next, access the running Website:

1. Click on the <walkthrough-spotlight-pointer spotlightId="devshell-web-preview-button" target="cloudshell">Web Preview button</walkthrough-spotlight-pointer> in the upper right of the editor window. 
2. Select **Change port** and enter `5000`. 
3. Click **Change and Preview**.

Your running website will open in a new window.


## Conclusion
<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>
Congratulations! You've successfully run the Emblem Website.

<walkthrough-inline-feedback></walkthrough-inline-feedback>
