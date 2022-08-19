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

### Run web app locally

```bash
npm install
npm build 
npm run start
```

Open your browser to `localhost:8000`.

### Run auth api locally

```bash
npm install
npm run start
```

Server will run at `localhost:4000`.


## Deploying containers

```bash
export PROJECT_ID=<YOUR_PROJECT_ID>
```

Requires the following environment variables to be set within each Cloud Run container.

| Env Vars       | Description                                 | Example                                    |
| -------------- | ------------------------------------------- | ------------------------------------------ |
| API_URL        | path that points to server api              | `https://content-api-abc123-uc.a.run.app`  |
| SITE_URL       | path that points to current client web app  | `https://lit-website-abc123-uc.a.run.app`  |
| AUTH_API_URL   | path that points to nodejs auth api url     | `https://lit-auth-api-abc123-uc.a.run.app` |
| REDIRECT_URI   | path that points to AUTH_API_URL callback   | `${AUTH_API_URL}/auth/google`              |

| Secrets        | Description                                                       |                                                                                  |
| -------------- | ----------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| JWT_SECRET     | String to encode jwt token (only required for auth api container) | `random-value-emblem-string`                                                     |
| CLIENT_ID      | OAuth 2.0 credentials client id                                   | From [web client credentials](https://console.cloud.google.com/apis/credentials) |
| CLIENT_SECRET  | OAuth 2.0 credentials client secret                               | From [web client credentials](https://console.cloud.google.com/apis/credentials) |


### Lit container

```bash
gcloud builds submit --tag $REGION-docker.pkg.dev/$PROJECT_ID/website/lit-based-website

gcloud run deploy --image=$REGION-docker.pkg.dev/$PROJECT_ID/website/lit-based-website --port 8000

gcloud run services update lit-based-website \
  --update-env-vars REDIRECT_URI=$(your-redirect-uri) \
  --update-env-vars API_URL=$(your-api-url) \
  --update-env-vars AUTH_API_URL=$(your-auth-api-url) \
  --update-env-vars SITE_URL=$(your-client-site-url) \
  --update-secrets CLIENT_ID=$(your-client-id) \
  --update-secrets CLIENT_SECRET=$(your-client-secret)
```

### Auth API container

```bash
cd server/

gcloud builds submit --tag $REGION-docker.pkg.dev/$PROJECT_ID/website/lit-auth-api

gcloud run deploy --image=$REGION-docker.pkg.dev/$PROJECT_ID/website/lit-auth-api --port 4000

gcloud run services update lit-auth-api \
--update-env-vars REDIRECT_URI=$(your-redirect-uri) \
--update-env-vars JWT_SECRET=$(your-jwt-secret) \
--update-env-vars SITE_URL=$(your-client-site-url) \
--update-secrets CLIENT_ID=$(your-client-id) \ 
--update-secrets CLIENT_SECRET=$(your-client-secret)
```

## Learning

Want to learn more frontend [resources](docs/resources.md)? This includes tooling used for this project.

## Contribution

Interested in helping out? Follow the yellow brick road to this [guide](docs/contribution_guide.md).

## Code of Conduct

Please read through our [code of conduct](docs/code_of_conduct.md)
