# How to Contribute

We are not currently accepting patches for this project. If you'd like to get a head start on becoming a contributor however, you can review the information below.

## Contributor License Agreement

Contributions to this project must be accompanied by a Contributor License
Agreement (CLA). You (or your employer) retain the copyright to your
contribution; this simply gives us permission to use and redistribute your
contributions as part of the project. Head over to
<https://cla.developers.google.com/> to see your current agreements on file or
to sign a new one.

You generally only need to submit a CLA once, so if you've already submitted one
(even if it was for a different project), you probably don't need to do it
again.

## Community Guidelines

This project follows
[Google's Open Source Community Guidelines](https://opensource.google/conduct/) as well as the included [Code of Conduct](/CODE_OF_CONDUCT.md).

## Proposing Changes

We represent business requirements as "User Journeys". Each user journey may represent a new use case for the application, an operational requirement for the architecture, or a demo requirement for how this application is used as a learning resource.

Journeys should be created via the [User Journey Proposal](https://github.com/GoogleCloudPlatform/emblem/issues/new?assignees=&labels=status%3A+investigating%2C+priority%3A+p2%2C+type%3A+journey&template=user_journey.md&title=%28Journey%29+UJ1%3A+Journey+Title) template.

For more incremental changes, a feature request will be considered but should relate to an existing User Journey.

## Design & Project Philosophy

### Positive & Helpful in Feedback

Whether it's a code review, a static analysis outcome, or an error message in the app, our goal is to enable contributor and user success.

* Warnings & errors should provide context, suggest next steps, and provide direct access to more details. (For example, link to build logs.)
* When a warning or error has a generally agreed fix or next step, point the way or suggest the fix. (For example, linting checks on a PR should propose the fixes to correct the code formatting.)

## Significant Contributions

**Significant contributions** change the architecture, developer experience, or add exciting new capabilities to the application. This requires making technical decisions, and in this project we do our best to capture the considerations in these moments to tell a story of software evolution and preserve context to revisit our design.

Every significant contribution is expected to [add a decision record](docs/decisions.md). To make sure implementation time is not wasted, please propose design in an issue before opening a code editor.

## Code Reviews

All submissions, including submissions by project members, require review. We
use GitHub pull requests for this purpose. Consult
[GitHub Help](https://help.github.com/articles/about-pull-requests/) for more
information on using pull requests.

## Automated Testing & Productivity

The following automated checks are run against every Pull Request:

* *cla/google*: Ensure Google's [Contributor License Agreement](#contributor-license-agreement) has been met for the proposed change.
* *[header-check](https://github.com/googleapis/repo-automation-bots/tree/master/packages/header-checker-lint)*: Ensure all applicable files have copyright headers.
* *[style-terraform](/.github/workflows/style-terraform.yml)*: Propose corrections in PRs that add `terraform fmt` violations.

### Creating a New Static Analysis Check

If no Google Cloud resources are needed, use [GitHub Actions](https://docs.github.com/en/actions) to drive automation.

Based on the philosophy [Positive & Helpful Feedback](#positive-helpful-feedback), where it's possible to [make suggestions to a Pull Request](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/reviewing-changes-in-pull-requests/incorporating-feedback-in-your-pull-request) to help it conform with a check, do that in addition to any required failures. [googleapis/code-suggester](https://github.com/googleapis/code-suggester) is a good example of a tool that minimizes contributor toil.
