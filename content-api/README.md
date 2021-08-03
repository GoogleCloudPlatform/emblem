# Emblem REST Api Server

This folder contains the software for the Emblem REST API.

The (OpenAPI specification of this API)[./openapi.yaml] defines
the operations and data for this API.

Most application developers should use the (Client Libraries)[../client-lib]
instead of directly sending requests to the API itself.

## Running Locally

Run the Cloud Firestore emulator:

1. Install the (Cloud Firestore emulator)[https://cloud.google.com/sdk/gcloud/reference/beta/emulators/firestore]

2. Open a local command shell and run

    https://cloud.google.com/sdk/gcloud/reference/beta/emulators/firestore

3. Look in the output of that command for a line like

    `export FIRESTORE_EMULATOR_HOST=127.0.0.1:8080`

4. If the address and port number are not an IPv4 as above (four integers
separated by `.` followed by `:` and another integer), kill the running
emulator with CTRL-C or CMD-C, then repeat the command, but add the flag
shown below. If port 8080 is not available, select another unused port
number.

    `--host-port 127.0.0.1:8080`

Run software that will use Cloud Firestore (such as the test suite
or an application website) with
the environment variable FIRESTORE_EMULATOR_HOST set the value shown
when you ran the emulator.

## Testing Locally

The test suite uses *application default credentials* to get an
identity token needed to authenticate API requests. The test suite
authenticates every request using these credentials.

### Create a test service account

Authenticated requests require a account that can be authenticated
by the Google Identity Platform. Any account of that kind can be
used; it does not have to be a user or service account with
permission in any specific project.

You must create a testing service account and download a key file
for it. You only need to do this one to run one or more local
tests.

1. Create a testing service account for a project using the
(Google Cloud console)[https://console.cloud.google.com/]. It does
not matter which project is used. Do not grant this service account
any additional access when asked. Note the email address of the
service account shown in the console.
2. (Create and download a JSON service account key)[https://cloud.google.com/iam/docs/creating-managing-service-account-keys#iam-service-account-keys-create-console].
Even though this service account has very little power, you should still guard
the downloaded key carefully. Note the full path to the key file.

### Seed the local test database

The test database will need to have an Approver resource with the same
email address as the test service account. Approvers can perform all
API operations, including designating campaign managers. This step
will create that Approver resource.

1. Set the environment variable `GOOGLE_APPLICATION_CREDENTIALS` to the
full path you noted in the previous step.
2. "Seed" the local Emblem API test Cloud Firestore database with this service
account as an approver. This must be done first so that test API
calls can be authenticated to this account. Run the program `seed_test_approver.py`
in the `data` directory to do this. Specify the test account's email
address when running the command.

    python data/seed_test_approver.py <EMAIL_ADDRESS>

You will need to do this every time to launch a new test database. By
default, that database does not persist from one run to the next, though
its contents can be exported and later imported if desired.

### Run the test suite

In the directory that includes this README, open a command shell, and run
the following commands commands below. It is recommended that you create and
active a (*virtualenv* virtual environment)[https://virtualenv.pypa.io/en/latest/index.html]
before doing this.

    pip install -r requirements.txt
    pip install -r requirements-test.txt
    pytest

## Testing in Google Cloud

