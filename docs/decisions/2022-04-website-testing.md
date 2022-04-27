# Testing the Website

 - Status: approved
 - Last Updated: 2022-04
 - Related issues: [#307](https://github.com/GoogleCloudPlatform/emblem/issues/307)
 - Related PRs: [#342](https://github.com/GoogleCloudPlatform/emblem/issues/342), [#361](https://github.com/GoogleCloudPlatform/emblem/issues/361)

## Goals

### Current Goals

✅ Detect glaring errors in the Website
✅ Minimize time-to-useful-data

### Potential future goals

These are currently **non-goals**. We expect that to change **during or after the Public Preview ("Beta") phase**.

❌ Simplify bug triage
❌ Improve contributor development velocity
❌ Create a truly-comprehensive set of tests

> **Note:** these goals are likely best addressed with what are known as _Unit Tests_, as opposed to _System/Integration Tests_.

## Decisions

### Testing Approach

In light of the goals above, we decided as a team to focus on **End-to-End (E2E) tests** prior to Public Preview.

### Tooling

As a team, we evaluated [several different tools](https://modern-web.dev/docs/test-runner/browser-launchers/overview/). We [came to the conclusion](https://github.com/GoogleCloudPlatform/emblem/issues/307#issuecomment-1111508110) that [Playwright](https://playwright.dev) was the best fit for our needs.

## Revision Criteria

We plan to revise this decision once Emblem enters Public Preview.

In particular, we plan to consider implementing unit tests **in between Public Preview and GA.**
