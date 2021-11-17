# Decision Log

In this project we capture important decisions with [architectural decision records](https://adr.github.io/).

These records provide context, trade-offs, and reasoning taken at our community & technical cross-roads. Our goal is to preserve the understanding of how the project has grown, and capture enough insight to effectively revisit prevision decisions.

Get started created a new decision record with the template:

```sh
cp template.md NN-title-with-dashes.md
```

## Previous Decision Records

TODO: Migrate decision records in this file to the new record-per-file format.

Each decision might have a **history** note, indicating where changes to earlier decisions might cause revisiting the current decision.

Decision records should attempt to follow the Y-statement format for consistency:

```md
In the context of **<use case/user story u>**, facing **<concern c>** we decided for **<option o>** and neglected <other options>, to achieve <system qualities/desired consequences>, accepting <downside d/undesired consequences>, because <additional rationale>.
```

## Decision: Using Cloud Run for Website and Content API

Deciding **which Serverless platform to use for the Website _and_ Content API**, facing the options of **Cloud Functions, App Engine, or Cloud Run**, we decided to **deploy to Cloud Run** for _both_ tasks.  Cloud Run has more flexibility than Cloud Functions or App Engine, and additionally offers concurrency and traffic splitting, allowing for a more natural canary rollout pipeline.

* **Date:** 2021/06

## Decision: Using Cloud Build Alpha for Pub/Sub Triggers

In order to handle cross-project triggers and canary rollouts, we are using the **alpha Cloud Build Pub/Sub triggers**.

For the canary rollouts, this decision was reached mainly because it is the only Cloud Build trigger type that can gracefully handle gradually increasing traffic on a deployment.  Alternatively, we could manage rollouts via:

 - A **Cloud Function**
 - A shell script
 - One very long explicit Cloud Build config

The Pub/Sub triggers are simpler, do not require any extra code to manage, and are DRY-er than having one long `cloudbuild.yaml` which repeats each step with slightly higher traffic percentages.  Ultimately, we will migrate to **Cloud Deploy**, which should manage rollouts for us.  As it is not yet available for Cloud Run, Pub/Sub triggers are our best option.

For cross-project triggers, Pub/Sub triggers allow us to limit the permissions granted to the Cloud Build service account in the source project.  If we handled all cross-project deployments this way, the service account would only need to have the Pub/Sub Publisher role in the 2nd project.

* **Date:** 2021/07

## Decision: Require both user and application authorization

Some of the API methods deal with person-specific information, such as donations, which have a donor ID and a
contribution amount. Calls to those methods will require an Authorization header with value 'Bearer _jwt_' where
_jwt_ is an identity token from Google Identity Platform.

Many API methods don't deal with particularly sensitive content, so do not require user authentication. However,
we don't want random requests being made to the API, so we require the application use the API to be
"registered". That is, it must have an API key that the owner of the REST API issues. All API requests
will require an API key as a query parameter, as in `GET /campaigns?api_key=registered_key`. Our REST API
will get a list of valid values from an environment variable. The client application will get the
specific value from an environment variable.

Note that this means that some requests use two authentication methods, one for the application using the
API, and one for the user requesting a sensitive operation.

* **Date:** 2021/07

## Decision: API tooling

Use OpenAPI to describe the API resources, operations, and authentication requirements. Then generate
client libraries with OpenAPI code generation tools.

Swagger-codegen was tried out, then openapi-generator-cli. Both are open source using the Apache License 2.0.
openapi-generator-cli was forked from swagger-codegen in 2018.

They are functionally nearly identical, but openapi-generator-cli has more options and is
more actively developed. The Swagger tool is owned by Smart Bear, while the OpenAPI tool
is community owned.

After using both, we will use openapi-generator-cli going forward.

## Decision: use Cloud Identity Platform for user authorization

### Rationale
[Cloud Identity Platform](https://cloud.google.com/identity-platform) is a Google Cloud-specific
layer on top of [Firebase Auth](https://firebase.google.com/docs/auth) that provides
several useful capabilities within GCP itself:

 - _Built-in user account management tools_ available in the [Cloud Console](https://console.cloud.google.com/customer-identity/users).
 - _Identity federation_, which combines sign-ons from a [wide variety](https://cloud.google.com/identity-platform/docs/concepts-authentication#key_capabilities) of identity providers (such as Google, Apple, and GitHub) into a single user identity.

The other option we reviewed, [Google Sign-in](https://developers.google.com/identity/sign-in/web/build-button), did not have either of these capabilities that we might want
to use later on. Thus, we decided to go with Cloud Identity Platform to "future-proof" our design.

Finally, we did not want to deal with the hassle of managing user credentials (such as passwords) ourselves.
Though this option gives the most _customizability_, we thought that the greater simplicity of Cloud Identity Platform was worth trading some flexibility for.

### Revision Criteria
In the unlikely event that we need to do something _not_ supported by Cloud Identity Platform,
then we may want to consider implementing a **username/password-based** authentication
system for additional flexibility.

* **Date:** 2021/07

## Decision: use cookies to store tokens minted by Cloud Identity Platform

Some calls to the API itself require a token that authenticates the current user. Since these calls
are performed _server-side_, we have to forward tokens (generated _client-side_) to the server.

### Rationale
Because our app is rendered serverside using an HTML-based templating language (`jinja2`),
any token-forwarding method we use must work with `GET` requests made by links (HTML `<a>` elements).
This disqualifies things like `POST` requests or [custom HTTP headers](https://stackoverflow.com/questions/3047711/custom-http-request-headers-in-html) to some extent, as both
do **not** work with standard HTML `<a>` elements and would require additional (and arguably non-idiomatic/hacky) frontend Javascript
to forward the token to the server.

Another alternative would have been to switch to a single-page app that calls backend APIs directly,
but that would have required a labor-intensive migration of all of our (`Jinja2`-based) views to frontend Javascript.

Finally, the Firebase documentation [explains how to create](https://firebase.google.com/docs/auth/admin/manage-cookies#create_session_cookie)
session cookies. The fact that this example is present in the official documentation implies
that this is a conceptually valid way of storing user authentication materials.

In our view, storing the token in a cookie was the cleanest solution
available for this problem - which is why we chose it.

### Revision Criteria
If a more straightforward and/or more secure method of storing these tokens becomes available
(either at the Firebase level, or the HTTP-specification level), we may consider migrating to that option.

(For example, we could do away with the `session` cookie if the Firebase client SDK somehow automatically forwarded a generated ID token to the backend with every request.)
