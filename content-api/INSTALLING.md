# Installing to Google Cloud Run

You will need to have a Google Cloud project available.
Use the [Google Cloud console](https://console.cloud.google.com/)
to prepare the test environment and run the API server.

## Prepare the Cloud Firestore database

Open the [Google Cloud console](https://console.cloud.google.com/)
in your browser.

1. [Navigate to Cloud Firestore](https://console.cloud.google.com/firestore/data) and select *Native* mode. This
can only be done once, before the database is used.
1. "Seed" the Emblem API Cloud Firestore database with the
the first _approver_. Click *Data* from the options at
the left side of the Cloud Firestore screen, then enter
the first approver:
    - Click *Start Collection*
    - Enter `approvers`, exactly as shown here, as the collection
    ID
    - Add the first approver to the collection. Do not
    enter a Document ID, Cloud Firestore will assign
    one.
    - For the first field in this first document, enter
    the *Field name* `kind` of type string with value
    `approvers`.
    - Click *Add field*, and create a field named `email`
    of type string. Use the email address of the person
    who will be the first Approver as the value.
    - Click *Add Field* and create a field named `name`
    of type string and fill in that person's name.
    - Click *Add Field* and create a field named
    `active` of type boolean, and value true.
    - Click *Save*

The person with this email address will be able to perform
all API operations as an Approver.

## Deploy the API server to Cloud Run

Open a command shell.

1. Navigate to the directory `content-api`.
1. Run the command `gcloud init` and set the email address
   to one that has permission to access the database. The
   email you used to create the project is fine. Also select
   the project you created the database in.
1. Create a container for the API server using Cloud Build. Replace
   _PROJECT_ in the command with your project ID.

        gcloud builds submit . --tag=gcr.io/_PROJECT_/content-api

    This will create a container image and save it in
    a container registry.

1. Deploy to Cloud Run.

        gcloud run deploy --image=gcr.io/_PROJECT_/content-api

The API server will be deployed and run. Note the
URI of the new service. This URI will need to be provided to
the Emblem website when it is installed.

# Finish

The server is live and available to an Emblem website.
