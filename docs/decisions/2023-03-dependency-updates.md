# Smarter dependency updates

* **Status:** approved
* **Last Updated:** 2023-03-27
* **Builds On:** [Automate Dependency Updates](2022-06-automate-dependencies.md), [Pin App dependencies](2022-06-pin-dependencies.md)
* **Objective:** Find ways to maximize the value and minimize the human effort around automated dependency updates.

## Context & Problem Statement

We previously setup [renovate](https://docs.renovatebot.com/) as a standard
tool our organization uses to automatically manage dependency updates. We used
a fairly basic initial configuration:

```json
{
  "extends": [
    "config:base"
  ],
  "ignorePaths": [
    "experimental/**"
  ],
  "rangeStrategy": "pin",
  "schedule": "before 10am every 3 weeks on Monday"
}
```

This configuration had the following intentions:

1. Do not update in experimental
2. Pin app dependencies to maximize build predictability for our app
3. Run renovate on the repository Monday morning every 3 weeks

However, we had the following problems:

1. Many update PRs: one per package update.
2. Constantly exceeding the default of 10 conurrently open PRs. We did not have
   insight into our true backlog depth.
3. PRs opening twice per hour on a business day meant someone proactively jumping
   on periodic maintenance would complete a few reviews then miss the pending updates.
4. A 3 week cycle seemed good; however, we work on a 2 week sprint.
   Misalignment makes dependency update work more likely to be forgotten in planning.
5. Over time, we ran into failing tests for some updates. Ecosystems like
   [Python OpenTelemetry](https://opentelemetry.io/docs/instrumentation/python/)
   and [Playwright](https://playwright.dev/) require several of their discrete
   packages/resources to be updated in tandem.

To bring these pain points together:

How can we reduce the volume of work, boost the predictability of work, and
ensure automated updates result in mergeable Pull Requests?

## Priorities & Constraints <!-- optional -->

* Reduce maintenance workload for dependency updates
* Use PR count and age to understand work backlog
* Fix failing tests on dependency updates
* Ease in troubleshooting riskier updates later when bugs occur
* Avoid an overly complicated, opaque process configuration

## Considered Options

The following updates all included scheduling and rate limit changes.

* Option 1: Group all dependency updates
  * All dependency updates are grouped in one big bucket
  * Reviews & troubleshooting
  would be painful, but updates easily managed.

* Option 2: Group all non-major dependency updates
  * OpenTelemetry and Playwright updates are always grouped for testability
  * Major updates go through one by one.
  * Non-majors are grouped together across language and use.
  * Reviews and troubleshooting still painful, but riskier updates are siloed.

* Option 3: Option 2, sharded by Emblem Component
  * OpenTelemetry and Playwright updates are always grouped for testability
  * Major updates are individually opened
  * Emblem is divided into several components: website, content-api, delivery, demo-services.
  * Each of these may have separate reviewers.
  * Same problems as Option 2, with more PRs, but if something happens we might
    have an easier time building an investigation team.

* Option 4: Topical & Component Grouping
  * OpenTelemetry and Playwright updates are always grouped for testability
  * Major updates are individually opened
  * Non-major updates are grouped, as a fallback to all other rules
  * Non-major updates are split by component, language, and operational stance:
    * Website Python, Content API Python, Website Node.js, Website Node.js (build-only)
  * Terraform updates are grouped, so however we use terraform root modules they
    are in sync
  * Language/runtime updates are grouped, so we have a consistent language version
    and vulnerability surface.
  * Excluding update bundling for frameworks and packages that that are not covered
    by automated testing.

## Decision

Chosen option [Option 4: Topical & Component Grouping]

This option is expected to result in an acceptable volume of Pull Requests, each
of which has the breadth of impact and required reviewer skills scoped to be
assigned to a single engineer as an approachable task. Larger
groupings would be more likely to require multiple engineers in order to
cover the necessary expertise across languages and Emblem systems.

### Expected Consequences <!-- optional -->

* A more complex Renovate configuration, mitigated by using Renovate's support
  for JSON5 so we can include inline comments.

### Revisiting this Decision <!-- optional -->

This change has made our renovate configuration sufficiently complicated that we
expect additional iteration will be necessary. It has also helped our team
understand more of the power and opportunity in use of the renovate tool, which
may may take more advantage of in the future.

As part of the current implementation, we are postponing sharding major updates
by Emblem component, even though this may lead to an unwelcome entanglement of
riskier updates across more of Emblem.

## Links

* [PR #807](https://github.com/GoogleCloudPlatform/emblem/pull/807)
