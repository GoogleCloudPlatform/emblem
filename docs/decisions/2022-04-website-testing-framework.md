# End-to-End Website Testing Framework

* **Status:** approved
* **Last Updated:** 2022-04
* **Builds on:** [Website Testing Philosophy](2022-04-website-testing-philosophy.md)
* **Objective:** [description or link to contextual issue]

## Context & Problem Statement

There are several web-testing frameworks we could choose from. We need to determine which is best for the Emblem website's specific needs.


## Considered Options

* [Puppeteer](https://pptr.dev)
* [Playwright](https://playwright.dev)
* [Sauce Labs](https://saucelabs.com)
* [Cypress](https://cypress.io)

## Decision

We settled on **Playwright**, as **Cypress**, **Puppeteer* and **Sauce Labs** all had drawbacks for our use case.

#### Cypress
Cypress does not support tests that cover multiple different pages.

We discarded Cypress because we may need support for that in the future (even if we don't _right now_).

#### Puppeteer
Puppeteer [doesn't handle Shadow DOM](https://github.com/puppeteer/puppeteer/issues/858#issuecomment-438540596) very well. This is largely not a problem for server-side frontend frameworks (like Flask), but it will become a _very_ significant issue as we switch to the [Lit](https://lit.dev) client-side framework.

#### Sauce Labs
Sauce labs requires a separate account to function. Since Emblem instances need to be easy to set up, we did not want to add an additional step to the setup process.

### Revisiting this Decision

We plan to revise this decision if one or more of the following issues arise:
1) Playwright's goals and our needs no longer match up (due to changes on either side).
2) Playwright stops being maintained.

### Research

* [Puppeteer issue on Shadow DOM](https://github.com/puppeteer/puppeteer/issues/858#issuecomment-438540596)
* [Testing Framework guidance](https://modern-web.dev/docs/test-runner/testing-in-a-ci/)
* [Cypress vs. Playwright comparison](https://medium.com/sparebank1-digital/playwright-vs-cypress-1e127d9157bd)

## Links
* Related PRs
  - [End-to-end testing: inaugural implementation](https://github.com/GoogleCloudPlatform/emblem/pull/342)
  - [E2E testing: CI pipeline for CD image](https://github.com/GoogleCloudPlatform/emblem/pull/361)
  - [Decision Record on overall testing strategy for the Emblem Website](https://github.com/GoogleCloudPlatform/emblem/pull/363)
* Related User Journeys
  - [SJ4: Deploy a change](https://github.com/GoogleCloudPlatform/emblem/issues/26)
  - [SJ5: Rollback a bad change](https://github.com/GoogleCloudPlatform/emblem/issues/27)
* Related GitHub Issues
  - [Early discussion of Website testing strategy](https://github.com/GoogleCloudPlatform/emblem/issues/175)
