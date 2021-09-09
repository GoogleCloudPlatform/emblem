# Storing the config values

_Note: This process will be semi-automated with the setup script and terraform._

In order to set up automatic deployments for the website, the [config.py](https://github.com/GoogleCloudPlatform/emblem/blob/main/website/config.py) needs to read various values into the environment. 

For the less secret values, these will be created during the Terraform setup and stored as part of the Cloud Build trigger configuration.  The [config](https://github.com/GoogleCloudPlatform/emblem/blob/main/ops/deploy.cloudbuild.yaml) file will use substitutions to allow us to pass in various values.  

We could either set the environment variables in the Dockerfile or we could set the environment variables in the Cloud Run service.  We chose the latter for the sake of observability.  Cloud Run environment variables are visible in the UI when inspecting the revision. 

For more secret values like the API key, we will store it in Secret Manager and expose it as an environment variable in the Cloud Run service.  

To configure an API key with Secret Manager, please create a secret called `content-api-key`.

Next, add the cloudbuild service account to *only this* secret with the Secret Manager Secret Accessor role. Cloud Build will use this secret when deploying a new instance of the website. 

## Decision Background

The website depends on a `config.py` file to read in the Firebase API key and auth URL.  In the future, it will also need the Emblem content API key and URL, and possibly other configurable values.  These values should not be stored in the repo, because every new instance will have distinct values.  Our options are: 

1. Hardcode the values into the Cloud Build trigger as substitution variables, and use that to generate the `config.py`.  The API key is set on project creation and doesn’t change during CI/CD, so creating a stable trigger with the value is a good option.

1. When building the image in the Cloud Build pipeline, read from Secret Manager to generate the `config.py`.  The benefit here is showing the value of Secret Manager.  Additionally the config is meant to be "public" so it works to have it exposed in the container image.   It is also flexible, allowing us to update the configuration at later dates.  However, changing the `config.py` would require a new deployment, which is traceable and reversible. The downside is that Secret Manager is a billed resource.

1. Update the website code to read from environment variables instead of from `config.py`. We could store the variables in Secret Manager and expose them to Cloud Run as Environment Variables.  This would require changing some of the code in the website.  The other downside is that the values could be updated and potentially break the service without a new deployment, creating more stability risk. 

### Rationale
We've decided to do a combination of all three options.  We've written the `config.py` to dynamically read in environment variables.  The values of these variables are provided by either the Cloud Build trigger configuration or the Secret Manager, depending on the level of sensitivity.  
