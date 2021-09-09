# Emblem - Website

## Platform
This website is written using the
[Flask](https://flask.palletsprojects.com/en/2.0.x/) web framework for Python.

## Setup

### Downloading tools
To run this project, you'll need the following tools:

* Python (3.8 or higher)
* [pip](https://pypi.org/project/pip/)

The following tools are optional, but recommended:

* [pyenv](https://github.com/pyenv/pyenv)

### Installing dependencies
To install dependencies for the website, `cd` into the `website` directory and
run `pip install -r requirements.txt`.

### Setting up authentication
To enable end-user authentication within the application, you'll need to set up
[Cloud Identity Platform](https://cloud.google.com/identity-platform).

To do this, you must [configure Google as an Identity Platform](https://cloud.google.com/identity-platform/docs/web/google#configuring_as_a_provider) to enable G Suite-based authentication.

**Note:** end-user authentication is required to access
some - _but not all_ - application pages.

### Configuration
To configure the app, set the following environment variables:

---------------------------------------------------------------------------------------------
| **Variable name**             | **Description**                                           |
| `EMBLEM_FIREBASE_API_KEY`     | The Firebase API key provided by Cloud Identity Platform. |
| `EMBLEM_FIREBASE_AUTH_DOMAIN` | The auth domain (usually of the form `*.firebaseapp.com`) |
| `EMBLEM_API_URL`              | A URL pointing to your instance of the Emblem Content API |
---------------------------------------------------------------------------------------------

You can determine the `EMBLEM_FIREBASE_*` values by vising the
[Identity Providers page](https://console.cloud.google.com/customer-identity/providers) and clicking on the `Application Setup Details` button. The `EMBLEM_API_URL` value will be determined
by where you host the Content API. (If you're using Cloud Run, it will look something like `https://<SERVICE_NAME>-<HASH>.run.app`)

Congratulations! You are now ready to run the Emblem web app.

## Running
To run the web app, use the `flask run` command.
