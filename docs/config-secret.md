# Storing the config in Secret Manager

_Note: This process will be semi-automated with the setup script and terraform._

In order to set up automatic deployments for the website, we need to generate a `config.py` file like https://github.com/GoogleCloudPlatform/emblem/blob/main/website/config.default.py.  

To do this, please create a secret in Secret Manager called `auth-config`.  The value should be the entire value of the `config.py`, e.g.:

```
FIREBASE_API_KEY = "YOUR_FIREBASE_API_KEY"
FIREBASE_AUTH_DOMAIN = "YOUR_APP.firebaseapp.com"
```

Next, add the cloudbuild service account to *only this* secret with the Secret Manager Secret Accessor role. 

The [web-build.cloudbuild.yaml](https://github.com/GoogleCloudPlatform/emblem/blob/auth-cd/ops/web-build.cloudbuild.yaml) will use this secret to generate the config.

```
steps:
  # Generate config file from secret manager
  # Contains API Key and Firebase Auth URL
  - name: gcr.io/cloud-builders/gcloud
    entrypoint: /bin/bash
    secretEnv: CONFIG
    args: 
      - '-c'
      - |
        echo "$${CONFIG}" >> website/config.py
        
availableSecrets:
  secretManager: 
    - versionName: projects/${PROJECT_ID}/secrets/auth-config/versions/${_SECRET_VERSION}
      env: CONFIG
```

