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

To do this, you must complete two steps:
1. [Configure Google as an identity platform](https://cloud.google.com/identity-platform/docs/web/google#configuring_as_a_provider) to enable G Suite-based authentication
1. [Set up a Firebase project](https://firebase.google.com/docs/admin/setup#set-up-project-and-service-account) to use with Identity Platform
1. [Initialize the Firebase Admin SDK](https://firebase.google.com/docs/admin/setup#initialize-sdk) using a private key file

**Note:** end-user authentication is required to access
some - _but not all_ - application pages.

### Configuration
To configure the app, first rename `config.default.py` to `config.py`.

Then, specify the following values in `config.py`:
 - Your Firebase API key
 - Your Firebase Auth domain

You can determine these values by vising the
[Identity Providers page](https://console.cloud.google.com/customer-identity/providers) and clicking on the `Application Setup Details` button.

Congratulations! You are now ready to run the Emblem web app.

## Running
To run the web app, use the `flask run` command.
