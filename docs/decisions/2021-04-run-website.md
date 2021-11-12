# Host Website on Cloud Run

* **Status:** approved
* **Last Updated:** 2021-04
* **Builds on:** [Prefer Serverless](2021-03-serverless.md), [Python Default](2021-03-python-backend.md)
* **Objective:** Choose a hosting platform for the website/UI application.

## Context & Problem Statement

We are building a website/webapp as the user interface of the Giving app. It will be built in Python, based the [previous decision to default to Python](2021-03-python-backend.md) as the common application development language on the team.

Where should we run a human-facing website written in Python?

## Priorities & Constraints <!-- optional -->

* Websites should be snappy
* We will have various web assets to serve

## Considered Options

* Option 1: Cloud Run
* Option 2: App Engine (Standard)
* Option 3: Cloud Functions
* Option 4: Firebase Hosting + Cloud Functions

## Decision

Chosen option [Option 1: Cloud Run]

We discarded [Option 3: Cloud Functions] right away: it's not a good fit for general web serving.

We discarded [Option 4: Firebase Hosting + Cloud Functions] almost as quickly. While that model would work, we're starting with an approach of dynamically generating a lot of the HTML markup with Python, this might work in the future but not during MVP.

This left us with Cloud Run or App Engine.

The page [App Hosting on Google Cloud](https://cloud.google.com/hosting-options) suggests that backend apps in Flask or Django should use Cloud Run.

It further points out that Cloud Run (and not App Engine) enables Custom system packages, WebSockets, managed events-driven architectures, and running languages beyond the 7 supported on App Engine. This provides more flexibility to evolve the tech stack later.

Looking closer (and looking ahead to rollout/rollback plans), Cloud Run's traffic management features look really powerful.

### Expected Consequences <!-- optional -->

App Engine's been around longer, so there may be more content and guidance available.

Google Search:
* `how to build an app on "App Engine"` has 170,000 published since 2016
* `how to build an app on "Cloud Run"` has 51,000 results published since 2016

### Research <!-- optional -->

https://cloud.google.com/hosting-options