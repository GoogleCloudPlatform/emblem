# Emblem Giving frontend application

## Quicklinks
* [Requirements](requirements)
* [Getting Started](#getting-started)
* [Learning](requirements)
* [Contribution](#contribution)
* [Code of Conduct](#code-of-conduct)

## Requirements

Please have [node](https://nodejs.org/en/ ) 14 & npm 8 or higher installed.

## Get started

Within your terminal, open one tab to run the proxy and another to run the app.

```bash
npm install
npm build 
npm run start
```

To run locally:

- `npm start` runs your app for development on port `8000`, reloading on file changes

## Deploying Lit container

```
// Requires the following environment
// variables to be set Cloud Run container

REDIRECT_URI - uri pointing to auth api callback (i.e */auth/google)
API_URL - url that points to server api to obtain cause/campaign information
SITE_URL - url that points to current client app (this app)
AUTH_API_URL - url that points to nodejs auth api url

CLIENT_ID - oauth client id
CLIENT_SECRET - oauth client secret
```

```bash
export PROJECT_ID = your-project-id

gcloud builds submit --tag gcr.io/$PROJECT_ID/lit-auth-website

gcloud run deploy --image=gcr.io/$PROJECT_ID/lit-auth-website --port 8000

gcloud run services update lit-auth-website \
--update-env-vars REDIRECT_URI=$(your-redirect-uri),API_URL=$(your-api-url),AUTH_API_URL=$(your-auth-api-url),SITE_URL=$(your-client-site-url) \
--update-secrets CLIENT_ID=$(your-client-id),CLIENT_SECRET=$(your-client-secret)

```

## Deploying Auth API container

```
// Requires the following environment
// variables to be set in Cloud Run container

REDIRECT_URI - uri pointing to auth api callback (i.e */auth/google)
SITE_URL - url that points to current client app (this app)
JWT_SECRET - string to encode jwt token

CLIENT_ID - oauth client id
CLIENT_SECRET - oauth client secret
```

```bash
export PROJECT_ID = your-project-id

gcloud builds submit --tag gcr.io/$PROJECT_ID/lit-auth-api

gcloud run deploy --image=gcr.io/$PROJECT_ID/lit-auth-api --port 4000

gcloud run services update lit-auth-api \
--update-env-vars REDIRECT_URI=$(your-redirect-uri),JWT_SECRET=$(your-jwt-secret),SITE_URL=$(your-client-site-url) \
--update-secrets CLIENT_ID=$(your-client-id),CLIENT_SECRET=$(your-client-secret)
```

To run locally:

- `npm start` runs the auth server to target api on port `4000`


## Learning

Want to learn more frontend [resources](docs/resources.md)? This includes tooling used for this project.

## Contribution

Interested in helping out? Follow the yellow brick road to this [guide](docs/contribution_guide.md).

## Code of Conduct

Please read through our [code of conduct](docs/code_of_conduct.md)

