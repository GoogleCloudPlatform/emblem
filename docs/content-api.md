# Emblem - Content API

![Emblem Application architecture diagram](../docs/images/application.png)

The Emblem Content API is responsible for data management, business requirements, and transaction management.

## Design

The Emblem Content API is configured as a Cloud Run service written using the [Flask](https://flask.palletsprojects.com/en/2.0.x/) web framework for Python. The [OpenAPI specification](./openapi.yaml) defines the operations and data for this API.

Most application developers should use the [Client Libraries](../client-libs) instead of directly sending requests to the API itself.

The Content API uses the following Google Cloud services:

* **Cloud Firestore** - stores application data
* **Cloud Logging** - creates structured log entries

Emblem uses a testing & delivery pipeline to automate deployment of the web application (Website & Content API) and setup of operations management.

To deploy the Emblem Content API manually, either launch the [Quickstart](#quickstart) interactive tutorial or follow the [Setup](#setup) guide below.

## Interactive Walkthrough for Setup

Learn how to run the API by following an interactive tutorial on Cloud Shell, a free browser-based IDE that comes preconfigured with the necessary tools to run Emblem. Click the button below to clone Emblem into a Cloud Shell instance and launch the interactive tutorial:

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https%3A%2F%2Fgithub.com%2FGoogleCloudPlatform%2Femblem&cloudshell_tutorial=docs%2Ftutorials%2Fapi-quickstart.md)

Once your Emblem Content API is running, you can deploy the Emblem Website to interact with the API by launching the [Website Quickstart on Cloud Shell](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https%3A%2F%2Fgithub.com%2FGoogleCloudPlatform%2Femblem&cloudshell_tutorial=docs%2Ftutorials%2Fwebsite-quickstart.md).

## Manual Instructions for Setup

You will need to have a Google Cloud project available.
Use the [Google Cloud console](https://console.cloud.google.com/)
to prepare the test environment and run the API server.

### Prepare the Cloud Firestore database

Open the [Google Cloud console](https://console.cloud.google.com/)
in your browser.

1. [Navigate to Cloud Firestore](https://console.cloud.google.com/firestore/data)
and select **Native** mode. This can only be done once, before the database is used.
1. "Seed" the Emblem API Cloud Firestore database with the
the first `approver`. Click **Data** from the options at
the left side of the Cloud Firestore screen, then enter
the first approver:

    * Click *Start Collection*
    * Enter `approvers`, exactly as shown here, as the collection ID
    * Add the first approver to the collection. Do not enter a Document ID,
      Cloud Firestore will assign one.
    * For the first field in this first document, enter the *Field name* `kind`
      of type string with value `approvers`.
    * Click **Add field**, and create a field named `email` of type string. Use
      the email address of the person who will be the first Approver as the value.
    * Click **Add Field** and create a field named `name` of type string and
      fill in that person's name.
    * Click **Add Field** and create a field named `active` of type boolean,
      and value `true`.
    * Click **Save**

The person with this email address will be able to perform all API operations as an Approver.

### Seed Database

To mimic a real-world production instance, you can seed the Firestore database with sample data. Add fake campaigns, causes, donors, and donations by running the [`seed_database`](./data/seed_database.py) script:

    python seed_database.py

This script imports content from [`sample_data.json`](./data/sample_data.json). The campaigns, causes, donors, and donations in the sample data are fictional.

Once the database has been seeded, you can interact with the data by running the [Website](../website/README.md) or by making requests to the API directly.

    # Get the URL from your deployed API.
    export EMBLEM_API_URL=$(gcloud run services describe content-api --project $PROJECT_ID --format "value(status.url)")

    # Make an HTTP request to get a "cause" entry.
    curl -X GET $EMBLEM_API_URL/causes/6aee60eead3741a98f15

### Deploy the API server to Cloud Run

1. Navigate to the directory `content-api`.
1. Run the command `gcloud init` and set the email address
   to one that has permission to access the database. The
   email you used to create the project is fine. Also select
   the project you created the database in.
1. Set the variable `PROJECT_ID` to the project you selected in the previous step by running the following command:

        export PROJECT_ID=$(gcloud config get-value project)

1. Create a container for the API server using Cloud Build.

        gcloud builds submit . --tag=gcr.io/$PROJECT_ID/content-api

    This will create a container image and save it in
    a container registry.

1. Deploy to Cloud Run.

        gcloud run deploy --image=gcr.io/$PROJECT_ID/content-api

The API server will be deployed and run. Note the
URI of the new service. This URI will need to be provided to
the Emblem website when it is installed.

## Running Locally

1. Create or use an existing Google Cloud Project. Even though the
   server code will run locally, the data will be in a project's
   Firestore database.

2. Follow the instructions to [Prepare the Cloud Firestore Database](#prepare-the-cloud-firestore-database) and [Seed the Database](#seed-database).

3. In the cloud console, navigate to IAM Admin/Service Accounts, and
   either select a service account with Firestore access, or create
   a new one, then create and download a key to a local JSON file.
   **NOTE: this is dangerous for your project's security, and these
   instructions will be updated with a better option in the future.**
   See the [documentation](https://cloud.google.com/iam/docs/creating-managing-service-account-keys#iam-service-account-keys-create-console).

4. In a shell, run `gcloud init` to select the proper user and
   project.

5. In the same shell, set the GOOGLE_APPLICATION_CREDENTIALS environment
   variable the the path of the downloaded JSON key file.

6. In the folder with this README.md file, run `python main.py`.

7. Open a browser or use `curl` or test code to interact with
   the server at the address and port number displayed. This is
   usually `http://127.0.0.1:8080`.

## Running Local Tests

### Prepare the test identity

The test suite uses *application default credentials* to get an
identity token needed to authenticate API requests. The test suite
authenticates every request using these credentials. We will
create a test account and use its credentials for testing.

Authenticated requests require a account that can be authenticated
by the Google Identity Platform. Any service account can be
used; it does not have to be a user or service account with
permission in any specific project.

You must create a test service account and download a key file
for it. You only need to do this once to run one or more local
tests.

1. Create a test service account for a project using the
[Google Cloud console](https://console.cloud.google.com/). Do not
grant this service account any additional access, and (optionally)
remove any default permissions. Note the service account's
email address shown in the console.
2. [Create and download a JSON service account key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys#iam-service-account-keys-create-console).
Guard
the downloaded key carefully. Note the full path to the key file.

### Run the test suite

In the directory that includes this README, open a command shell, and run
the following commands commands below. It is recommended that you create and
activate a [*virtualenv* virtual environment](https://virtualenv.pypa.io/en/latest/index.html)
before doing this.

    pip install -r requirements.txt
    pip install -r requirements-test.txt
    pytest

This will run the test suite and report any failures.

## Approver Seeding CLI

The database will need to have an `Approver` resource with the same
email address as the test service account. Approvers can perform all
API operations, including designating campaign managers. This step
will create that `Approver` resource.

If you do not want to use Cloud Console to set up an approver, you can use
the approver seeding script from any authenticated machine.

1. Set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable to
   the full path you noted in the previous step.
1. "Seed" the local Emblem API test Cloud Firestore database with this
   service account as an approver.
1. Navigate to `../content-api/data`
1. Run the seeding script:

        python data/seed_test_approver.py <YOUR_EMAIL_ADDRESS>

You will need to do this every time you launch a new database.

## Use the Cloud Firestore emulator

You may use the Cloud Firestore emulator if working with data in the Cloud
introduces too much latency. Warning: This is not a standard workflow and these
instructions may be out of date.

1. Install the [Cloud Firestore emulator](https://cloud.google.com/sdk/gcloud/reference/beta/emulators/firestore)

2. Open a local command shell and run

    gcloud alpha emulators firestore start

3. Look in the output of that command for a line like

    `export FIRESTORE_EMULATOR_HOST=127.0.0.1:8080`

4. If the address and port number are not an IPv4 address as above (four integers
separated by `.` followed by `:` and another integer), kill the running
emulator with CTRL-C or CMD-C, then repeat the command, but add the flag
shown below. If port 8080 is not available, select another unused port
number.

    `--host-port 127.0.0.1:8080`

Run software that will use Cloud Firestore (such as the test suite
or an the API server) with the environment variable
`FIRESTORE_EMULATOR_HOST` set to the value shown when you ran the emulator.

You will need to open another command shell to run the tests
while the emulator is still running in the first shell.

When you are done with the emulator, return to the command shell running it
and enter *CTRL-C* until the it exits.
