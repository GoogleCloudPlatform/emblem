# Run the Emblem Giving Website locally on Cloud Shell
##
This tutorial shows you how to quickly run the Emblem Giving Website with Flask. You'll use Cloud Shell, a free browser-based IDE.

The Website requires a deployed instance of the Emblem Giving API in order to function properly. You can deploy the Content API on Cloud Shell by following the [API Quickstart Tutorial](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/emblem&cloudshell_git_branch=main&cloudshell_tutorial=docs/tutorials/api-quickstart.md).

For the best experience, launch this tutorial as an interactive walkthrough on Cloud Shell: [Open in Cloud Shell](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/emblem&cloudshell_git_branch=main&cloudshell_tutorial=docs/tutorials/website-quickstart.md).

Let's get started!

## Clone Emblem from GitHub
If you've cloned the Emblem Giving repository using the **Open in Cloud Shell** link, you can skip this step. Otherwise, manually clone the repo and `cd` into the `website` folder:
```bash
git clone https://github.com/GoogleCloudPlatform/emblem.git
cd emblem/website
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

## Set Emblem environment variables

In the Cloud Shell terminal, set the following environment variables:
1. `EMBLEM_FIREBASE_API_KEY`: The Firebase Web API Key provided by Cloud Identity Platform. You can find the key in the Firebase Console under [Project Settings](https://console.firebase.google.com/u/3/project/{{project-id}}/settings/general)
```bash
export EMBLEM_FIREBASE_API_KEY=<your-api-key>
```
2. `EMBLEM_FIREBASE_AUTH_DOMAIN`: The auth domain, usually of the form `{{project-id}}.firebaseapp.com`
```bash
export EMBLEM_FIREBASE_AUTH_DOMAIN={{project-id}}.firebaseapp.com
```
3. `EMBLEM_API_URL`: A URL pointing to your instance of the Emblem Content API  
```bash
export EMBLEM_API_URL=http://localhost:8080
```

Once you have set these environment variables, click **Next**.


## Run the Website

Now you can run and preview the Website.

  1. Install the application dependencies:
```bash
pip3 install -r requirements.txt
```

  2. Run the Website using Flask:
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
