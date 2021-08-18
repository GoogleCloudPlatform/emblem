# Testing the REST Api Server

Create a folder on your PC to work in, and copy this
Emblem `content_api` directory to that folder.

Open a command shell and navigate to that folder. You will
run the tests locally on this machine.

## Run the Cloud Firestore emulator

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

## Testing Locally

You will need to open another command shell to run the tests
while the emulator is still running in the first shell.

*Set the environment variable `FIRESTORE_EMULATOR_HOST` to the
value shown when you started the emulator.*

The test suite uses *application default credentials* to get an
identity token needed to authenticate API requests. The test suite
authenticates every request using these credentials. We will
create a test account and use its credentials for testing.

### Create a test service account

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

### Seed the local test database

The test database will need to have an `Approver` resource with the same
email address as the test service account. Approvers can perform all
API operations, including designating campaign managers. This step
will create that `Approver` resource.

1. Set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable to the
full path you noted in the previous step.
1. "Seed" the local Emblem API test Cloud Firestore database with this service
account as an approver. This must be done first so that test API
calls can be authenticated to this account. Run the program `seed_test_approver.py`
in the `data` directory to do this. Specify the test account's email
address when running the command.

    python data/seed_test_approver.py <EMAIL_ADDRESS>

You will need to do this every time you launch a new test database. By
default, the database does not persist from one run to the next, though
its contents can be exported and later imported if desired.

### Run the test suite

In the directory that includes this README, open a command shell, and run
the following commands commands below. It is recommended that you create and
activate a [*virtualenv* virtual environment](https://virtualenv.pypa.io/en/latest/index.html)
before doing this.

    pip install -r requirements.txt
    pip install -r requirements-test.txt
    pytest

This will run the test suite against the local Cloud Firestore emulator
and report any failures.

## Shut down the Cloud Firestore emulator

Once the tests pass, return the command shell running the Cloud Firestore
emulator and enter _CTRL-C_ until the emulator exits.
