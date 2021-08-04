# Decision Log

This project captures important decisions in the evolution of the project with [architectural decision records](https://adr.github.io/). These records provide a sense of context, trade-offs, and direction taken at various project cross-roads. The goals are to preserve an understanding of how the project has grown, and the conditions under which previous decisions might be revisted.

Each decision might have a **history** note, indicating where changes to earlier decisions might cause revisiting the current decision.

Decision records should attempt to follow the Y-statement format for consistency:

```md
In the context of **<use case/user story u>**, facing **<concern c>** we decided for **<option o>** and neglected <other options>, to achieve <system qualities/desired consequences>, accepting <downside d/undesired consequences>, because <additional rationale>.
```

## Decision: Use a two-folder-level split for Jinja templates

In order to organize our Jinja HTML templates, we decided to **use a two-level folder level split**. This will be combined with Jinja inheritance (i.e. the `extends` clause) for common components where possible.

Concretely, our _templates_ file architecture might look like this:
```
website/
  templates/
    campaigns/
      view_campaign.html
      create_or_edit_campaign.html
    users/
      view_user.html
    ...
```

See [this GitHub issue](https://github.com/GoogleCloudPlatform/emblem/issues/37) for more information.

### Rationale
Templates often mirror API actions (`create`, `read`, `update`, `delete`, etc). Since the API itself is organized by data types (e.g. `users`, `donations`, `causes`, etc), we saw it fit to mirror that information hierarchy here.

### Revision Criteria
We will review this decision if the number of templates per file becomes difficult to manage and/or keep track of.

We may also review this decision if large changes to the API occur. However, we are not expecting any such changes.

## Decision: Use a one-folder-level split for Flask view functions

In order to organize our Flask view functions, we decided to **use a single folder level split combined with Flask blueprints**.

Concretely, our _views_ file architecture might look like this:
```
website/
  views/
    campaigns.py
    users.py
    ...
```

See [this GitHub issue](https://github.com/GoogleCloudPlatform/emblem/issues/37) for more information.

### Rationale
Flask views themselves are (usually) no more than 5-10 lines of code. A one-folder-level split is not too high-level (which makes finding _individual views_ difficult) and not too low-level (which would make finding _the file associated with a view_ more difficult).

### Revision Criteria
If views start becoming longer, or each file starts to accrue more views than we can reason about at a time, we may opt for a greater degree of splitting between views.

We do not expect the total number of views to become smaller and/or less complex, however - and thus, we do not expect to opt for a lesser degree of splitting.

* **Date:** 2021/06

## Decision: Frontend Avoids JS Frameworks

In the context of the **frontend tech stack**, deciding to use plain JavaScript + libraries or use a rich framework such as Angular, React, or Vue, we decided to **use plain JavaScript to keep the frontend implementation approachable to backend developers**, accepting we will be less effective engaging with frontend engineers attempting to use serverless and may eventually outgrow a plain JavaScript code architecture.

* **Date:** 2021/03

## Decision: Backend Default Language is Python

In the context of the **backend tech stack**, deciding which languages to use for a web backend and API we decided to **default to Python** to maximize our use of language skills on the team that are also common across the industry, accepting many enterprise organizations use other languages for application implementation and may learn less from the application codebase.

* **Date:** 2021/03
* **Note:** The application code is not the focus for learning in this app.

## Decision: Monorepo for Code Management

In choosing how to **host code for development**, deciding between a monorepo and 3+ repositories, we decided to use a **monorepo pattern** to keep discovery & maintainability manageable, accepting additional complexity in pipeline configuration, needing extra caution to avoid creating an unintentional "decoupled monolith", and leaving use cases of multi-repo management outside our scope.

* **Date:** 2021/03

## Decision: Use Terraform for Infrastructure Management

In choosing how to **manage our Cloud Infrastructure**, deciding between ad hoc, scripted, or terraform-based approach, we decided to **use Terraform** in order to help customers engage with infrastructure as code in a serverless context, accepting more contributors will need extra time learning Terraform in order to contribute infrastructure changes.

* **Date:** 2021/03

## Decision: Use Terraform in a Single Directory

In choosing how to **manage our Terraform configuration for different services**, deciding between a central directory or spreading terraform config throughout the repository, we decided to use a **central directory** because it's easier to understand at the scale of this project, accepting it will be a less effective example for showing how multiple teams can separately own the infrastructure of their services.

* **Date:** 2021/03

## Decision: Deploy code with gcloud

In choosing how to **deploy services**, deciding between using Terraform to manage deployment, use gcloud "imperatively", or use product-specific configuration-as-code features, we decided to use **gcloud to imperatively manage services** because we want to keep infrastructure and software management separate and deployment operations familiar, accepting we are not addressing the ambiguity of service configuration including some infrastructural pieces.

* **Date:** 2021/03

## Decision: Use GitHub Actions for Static Analysis

In choosing how to **run static analysis and workflow automations**, deciding between Cloud Build and GitHub Actions, we decided to **use GitHub Actions because of it's simpler syntax, deeper GitHub integration, and thriving ecosystem of examples**, accepting this will create fewer opportunities to provide feedback to the Cloud Build product team.

* **Date:** 2021/03

## Decision: Rollbacks for Cloud Run use Traffic Splitting

In choosing how to **handle rollbacks for Cloud Run services**, deciding between
reverting deployments to a previous stable revision and rerouting traffic to a previous known-good revision, we decided to **re-route traffic** for highest recovery speed and least chance of unintended side-effects, accepting this capability is not consistent across all hosting platforms and does not address state management.

* **Date:** 2021/03

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

## Decision: use Cloud Identity Platform for user authorization

[Cloud Identity Platform](https://cloud.google.com/identity-platform) is a Google Cloud-specific
layer on top of [Firebase Auth](https://firebase.google.com/docs/auth) that provides
several useful capabilities within GCP itself:

 - _Built-in user account management tools_ available in the [Cloud Console](https://console.cloud.google.com/customer-identity/users).
 - _Identity federation_, which combines sign-ons from multiple identity providers (such as Google, Apple, and GitHub) into a single user account

 It also supports a [wide variety]() of identity providers, should our app need to support any additional such providers in the future.


* **Date:** 2021/07

## Decision: use cookies to store tokens minted by Cloud Identity Platform

Some calls to the API itself require a token that authenticates the current user. Since these calls
are performed _server-side_, we have to forward tokens (generated _client-side_) to the server.
Crucially, any method we use must work with `GET` requests made by links (HTML `<a>` elements).
This largely disqualifies things like `POST` requests or custom HTTP headers, as both would
require additional Javascript to inject the token into these link elements.

In our view, storing the token in a cookie was both the cleanest and most idiomatic solution
to this problem.

* **Date:** 2021/08
