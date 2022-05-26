# Emblem - Website

## Using Cloud Shell

Learn how to run the website by following an interactive tutorial on Cloud Shell, a free browser-based IDE that comes preconfigured with the necessary tools to run Emblem. Click the button below to clone Emblem into a Cloud Shell instance and launch the interactive tutorial:

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https%3A%2F%2Fgithub.com%2FGoogleCloudPlatform%2Femblem&cloudshell_tutorial=docs%2Ftutorials%2Fwebsite-quickstart.md)

> Note: some elements of the website will not function without a deployed instance of the Emblem Content API. Learn how to run the Content API by launching the [API Quickstart on Cloud Shell](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https%3A%2F%2Fgithub.com%2FGoogleCloudPlatform%2Femblem&cloudshell_tutorial=docs%2Ftutorials%2Fapi-quickstart.md).

## Locally

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
>**Note:** end-user authentication is required to access some - _but not all_ - application pages.

To enable end-user authentication within the application, see the [Website component's detailed documentation](../docs/website.md#setting-up-authentication).

### Configuration
To configure the Emblem website, see the [Website component's detailed documentation](../docs/website.md#configuration).

### Running

To run the website locally, use the `flask run` command. By default, the website will run on port `8080`.

## Seeding the Database

To seed the database Emblem uses, see the [Website component's detailed documentation](../docs/website.md#seeding-the-database).
