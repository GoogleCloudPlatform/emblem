# How to run this API server locally

1. Create or use an existing Google Cloud Project. Even though the
   server code will run locally, the data will be in a project's
   Firestore database.

1. In the cloud console, select Firestore DB in native mode to prepare
   for its use. It's fine for this database to be empty.

1. In the cloud console, navigate to IAM Admin/Service Accounts, and
   either select a service account with Firestore access, or create
   a new one, then create and download a key to a local JSON file.
   **NOTE: this is dangerous for your project's security, and these
   instructions will be updated with a better option in the future.**

1. In a shell, run `gcloud init` to select the proper user and
   project.

1. In the same shell, set the GOOGLE_APPLICATION_CREDENTIALS environment
   variable the the path of the downloaded JSON key file.

1. In the folder with this README.md file, run `python main.py`.

1. Open a browser or use `curl` or test code to interact with
   the server at the address and port number displayed. This is
   usually `http://127.0.0.1:8080`.
