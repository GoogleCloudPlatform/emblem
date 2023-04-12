# Passing Tests for Playwright Dependency Updates

* **Status:** approved
* **Last Updated:** 2023-03-31
* **Builds on:**
  * [Smarter dependency updates](2023-03-dependency-updates.md)
  * [End-to-End Website Testing Framework](2022-04-website-testing-framework.md)
  * [Website Testing Philosophy](2022-04-website-testing-philosophy.md)
* **Objective:** Enable playwright dependency updates to pass automatic testing.

## Context & Problem Statement

As previously explored in [smarter dependency updates](2023-03-dependency-updates.md),
Playwright requires a tighter level of synchronicity in updates between container
images and library packages than is typical.

In previous efforts, we began grouping updates, so a Dockerfile change and a test dependency change would happen in a single Pull Request. This was seen to work
because as part of testing the change, a manual action was taken to rebuild
our customized Playwright container image.

(We have a customized container image because we have tests written in Node.js,
but our test is locally running a Python app inside the Playwright container.
Revisiting this decision is not in scope.)

We do not want this manual action to be required because:

* If the update breaks, it will affect all other PRs and need a revert of code
  and a container rebuild.
* We do not want special cases in dependency update review that require the
  reviewer to take heightened responsibility for other changes in the queue.

## Priorities & Constraints <!-- optional -->

* Limited additional management/infrastructure management
* Low impact on review times for unrelated changes
* Avoid special cases for any one type of update

## Considered Options

* Option 1: Build playwright container as part of end-to-end test pipeline
* Option 2: Use the [Playwright for Python](https://playwright.dev/python/docs/docker) container image
* Option 3: Multi-container build step. Use Docker-in-Docker on Cloud Build (if 
  possible) or another mechanism to run a service in Python alongside playwright
  testing with an unmodified Playwright container image
* Option 4: Enrich the End-to-End Build step by deploying to Cloud Run

## Decision

Chosen option [Option 1] Build playwright container as part of end-to-end test
pipeline.

This option minimizes complexity and maintenance overhead. Option 2 had promise,
but does not include node.js runtime so we would have to rewrite our test suite.

### Expected Consequences <!-- optional -->

This will extend the length of time taken for the end-to-end tests, but it will
still be shorter than the overhead of deploying to Cloud Run. We will minimize
the impact by using smart [container image layer caching](docs/decisions/2023-03-31-container-builds-with-caching.md).

With this change, we are no longer maintaining an "authoritative" version of our
Playwright container. Instead, we are building whatever image the current branch
needs and relying on image caching to minimize the impact. As a result, merging
changes to the Playwright Dockerfile should always be done before or after the
bulk of maintance, to avoid switching costs of invalidating the container image
layer cache.

### Revisiting this Decision <!-- optional -->

We would prefer to have end-to-end tests that extend to Cloud Run.
We would prefer not to maintain a bespoke Playwright container image.

Either of these changes is likely to require over a week of effort that we do
not have as part of the available time for maintenance improvements.

## Links

* [#822](https://github.com/GoogleCloudPlatform/emblem/pull/822)
