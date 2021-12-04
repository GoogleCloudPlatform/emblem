# Deploy the Emblem Giving API using a Cloud Run Emulator
##
This tutorial shows you how to quickly deploy the Emblem Giving API to Cloud Run using a Cloud Run Emulator. You'll use Cloud Shell, a free browser-based IDE.

The Cloud Run Emulator comes built in to Cloud Shell. It allows you to configure an environment that is representative of your service running on Cloud Run, without incurring charges on your GCP billing account.

For the best experience, launch this tutorial as an interactive walkthrough on Cloud Shell: [Open in Cloud Shell](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/emblem&cloudshell_git_branch=main&cloudshell_tutorial=docs/tutorials/api-quickstart.md).

Let's get started!

## Set up Cloud Shell workspace
First, let's open the Emblem Giving API as the Cloud Shell [Workspace](https://cloud.google.com/shell/docs/workspaces).

1. If you've cloned the Emblem Giving repository using the **Open in Cloud Shell** link, you can skip this step. Otherwise, manually clone the repo and `cd` into the `emblem` folder:
```bash
git clone https://github.com/GoogleCloudPlatform/emblem.git
cd emblem
```

2. Open the API directory as the Cloud Shell Workspace by running the following command in the Cloud Shell <walkthrough-editor-spotlight spotlightId='menu-terminal'>terminal</walkthrough-editor-spotlight>:
```bash
cd content-api
cloudshell open-workspace .
```

## Set GCP project

In order to run the API, you'll need to use a new or existing [Google Cloud Platform project](https://cloud.google.com/resource-manager/docs/creating-managing-projects).

---

### Using an existing project
If you use an existing project, make sure that Cloud Firestore is enabled and configured to use [Native Mode](https://cloud.google.com/datastore/docs/firestore-or-datastore). Even though the server code will run locally, the data will be in a project's Firestore database.

### Creating a new project
If you need to create a new project for this tutorial, run the command below where `$PROJECT_ID` is the name of your new project:
```bash
export PROJECT_ID=emblem
gcloud projects create $PROJECT_ID
```
---
Set your new or existing project in Cloud Shell:
```bash
gcloud config set project $PROJECT_ID
```
To configure your project to use Firestore, navigate to [console.cloud.google.com/firestore](https://console.cloud.google.com/firestore) and select **Native Mode**.


## Create service account key

The Emblem Giving API uses a [service account](https://cloud.google.com/iam/docs/creating-managing-service-accounts) to authenticate requests to the Firestore database. In this section, you'll create a new service account or configure an existing one, then download a [service account key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys) to authenticate the API. 

1. To create a new service account, run the command below:
```bash
export SERVICE_ACCOUNT=emblem-shell-account
gcloud iam service-accounts create \
    $SERVICE_ACCOUNT --project \
    $PROJECT_ID
```

2. Give your service account permission to run Firestore with the role `roles/datastore.user`:
```bash
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com" --role="roles/datastore.user"
```

Using your new or existing service account, create a key and add it to `GOOGLE_APPLICATION_CREDENTIALS` in Cloud Shell.

1. Create and download a key, where `$SERVICE_ACCOUNT` is the name of your service account:
```bash
gcloud iam service-accounts keys \
    create $SERVICE_ACCOUNT-key.json --iam-account \
    $SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com
```

2. Set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable to the path of the key:
```bash
export GOOGLE_APPLICATION_CREDENTIALS=$SERVICE_ACCOUNT-key.json
```


## Deploy to Cloud Run Emulator

1. Click the <walkthrough-editor-spotlight spotlightId="cloud-code-status-bar">Cloud Code menu</walkthrough-editor-spotlight> on the status bar.

2. Select <walkthrough-editor-spotlight spotlightId="cloud-code-run-on-cloud-run-emulator">Run on Cloud Run Emulator</walkthrough-editor-spotlight> from the menu options. This launches the "Run/Debug on Cloud Run Emulator" wizard.

3. Under **Advanced Service Settings**, set the **Service account** to the full address of your service account, `{SERVICE_ACCOUNT}@{PROJECT_ID}.iam.gserviceaccount.com`

3. Click **Run**.    

The settings from the Run/Debug wizard are stored in <walkthrough-editor-open-file filePath='./.theia/launch.json'>launch.json</walkthrough-editor-open-file>. Subsequent deploys to Cloud Run will use these configurations.

The <walkthrough-editor-spotlight spotlightId="output">Output</walkthrough-editor-spotlight> window will display logs from the Cloud Run deployment.

4. If prompted, authorize gcloud to make API calls.

5. When the deployment is finished, the API's URL will be displayed in the output. Typically the URL will be `http://localhost:8080`. 

## Testing the API

### GET request
Run the curl command below to test your API:
```bash
curl -X GET http://localhost:8080/campaigns -H "Authorization: Bearer $(gcloud auth print-identity-token)"
```

It should return an empty response, since there aren't any campaigns in your database yet.

### POST request
Add a new campaign to your database using the API.

1. Create a new file `resource.json` with the following (or similar) content:
```
    {
        "name": "Demo Campaign",
        "description": "A campaign created to demonstrate the API",
        "cause": "Something useful",
        "managers": ["nobody@example.com", "nobodyelse@example.com"],
        "goal": 1000.00,
        "imageUrl": "https://github.githubassets.com/images/icons/emoji/unicode/1f4a0.png",
        "active": true
    }
```

2. Run the following curl request in the terminal:
```bash
curl -X POST http://localhost:8080/campaigns -H "Authorization: Bearer $(gcloud auth print-identity-token)" -H "Content-type: application/json" -d @resource.json
```
You should see success response that displays the created campaign data.

If you run the GET request again, you should see your newly created campaign in the response.

## Conclusion
<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>
Congratulations! You've successfully deployed the Emblem Giving API using the Cloud Run Emulator on Cloud Shell.

<walkthrough-inline-feedback></walkthrough-inline-feedback>

### What's next
- Keep your Content API instance running to use with the [Emblem Giving Website](https://github.com/GoogleCloudPlatform/emblem/tree/main/website). Learn how to run the Website by launching the Website Quickstart tutorial from your Cloud Shell terminal:
    ```bash
    teachme ../docs/tutorials/website-quickstart.md
    ```
