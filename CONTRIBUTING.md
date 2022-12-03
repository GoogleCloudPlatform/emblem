# Contributing guide

Thank you for your interest in contributing to Emblem! Please review this guide 
for important information before submitting issues or pull requests.

- [Contributing guide](#contributing-guide)
  - [Before you begin](#before-you-begin)
    - [Sign our Contributor License Agreement](#sign-our-contributor-license-agreement)
    - [Review our Community Guidelines](#review-our-community-guidelines)
  - [Design and project philosophy](#design-and-project-philosophy)
    - [Decision records for significant changes](#decision-records-for-significant-changes)
    - [Positive and helpful feedback](#positive-and-helpful-feedback)
    - [Toil automation](#toil-automation)
  - [Where to begin](#where-to-begin)
  - [Submitting GitHub issues](#submitting-github-issues)
  - [Pull requests](#pull-requests)
    - [Submitting a PR](#submitting-a-pr)
    - [Code Reviews](#code-reviews)
    - [User journeys](#user-journeys)
    - [Github workflows automation](#github-workflows-automation)

## Before you begin

### Sign our Contributor License Agreement

Contributions to this project must be accompanied by a Contributor License
Agreement (CLA). You (or your employer) retain the copyright to your
contribution; this simply gives us permission to use and redistribute your
contributions as part of the project. Head over to
<https://cla.developers.google.com/> to see your current agreements on file or
to sign a new one.

You generally only need to submit a CLA once, so if you've already submitted one
(even if it was for a different project), you probably don't need to do it
again.

### Review our Community Guidelines

This project follows [Google's Open Source Community Guidelines](https://opensource.google/conduct/) 
as well as the included [Code of Conduct](/CODE_OF_CONDUCT.md).

## Design and project philosophy 

### Decision records for significant changes

Significant changes to the architecture, developer experience, or dependencies
involve making critical decisions about future design needs.

As the project evolves, we capture these key decisions in [architectural 
decision records](docs/decisions). These decision records facilitate future 
engineering and provide developers with valuable historical context around some 
of the major technical components of Emblem.

See [`docs/decisions`](docs/decisions) for more information. 

### Positive and helpful feedback

Whether it's a code review, a static analysis outcome, or an error message in 
the app, our goal is to enable contributor and user success.

* Warnings & errors should provide context, suggest next steps, and provide 
direct access to more details. (For example, link to build logs.)
* When a warning or error has a generally agreed fix or next step, point the 
way or suggest the fix. (For example, linting checks on a PR should propose the 
fixes to correct the code formatting.)

### Toil automation

If you plan to automate codebase quality checks, consider using 
[googleapis/code-suggester](https://github.com/googleapis/code-suggester) to 
suggest changes.
Minimizing developer follow-up action is [helpful](#positive-helpful-feedback)!

If no Google Cloud resources are needed, use 
[GitHub Actions](https://docs.github.com/en/actions) to drive automation. 
Otherwise use Cloud Build 
([decision](docs/decisions/2021-05-static-analysis.md)).

Infrastructure (including test fixtures) should be managed automatically. This 
should be by Terraform where possible, and by custom scripts where necessary. 
([decision](docs/decisions/2021-04-terraform.md)) However, some cases exist 
where resources **cannot** be managed automatically. In those cases, Emblem 
allows for manual resource management 
([decision](docs/decisions/2022-07-test-fixtures.md)).

## Where to begin

Contributors can browse issues labeled 
[Help
Wanted](https://github.com/GoogleCloudPlatform/emblem/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc+label%3A%22help+wanted%22).  
Issues labeled 
[Good First
Issues](https://github.com/GoogleCloudPlatform/emblem/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc+label%3A%22good+first+issue%22) 
are recommended for new contributors.

## Submitting GitHub issues

We welcome all contributors to open GitHub issues in the repository for bugs, 
feature requests, and issues.  Please use the 
[provided issue templates](https://github.com/GoogleCloudPlatform/emblem/issues/new/choose)
when submitting issues and include log files and error output when applicable.  

## Pull requests 

### Submitting a PR

When submitting a PR, please provide a summary in the PR description of what 
changes are being made and the expected impact. Be sure to include any GitHub 
issues associated with the request and any other context that will be helpful
for review.  

### Code Reviews

All submissions, including submissions by project members, require review. We
use GitHub pull requests for this purpose. Consult
[GitHub Help](https://help.github.com/articles/about-pull-requests/) for more
information on using pull requests.

We recommend
[making suggestions to a Pull Request](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/reviewing-changes-in-pull-requests/incorporating-feedback-in-your-pull-request) 
to collaboratively fix problems.

### User journeys

We represent business requirements as "User Journeys". Each user journey may 
represent a new use case for the application, an operational requirement for 
the architecture, or a demo requirement for how this application is used as a 
learning resource.

Journeys should be created via the 
[User Journey Proposal](https://github.com/GoogleCloudPlatform/emblem/issues/new?assignees=&labels=status%3A+investigating%2C+priority%3A+p2%2C+type%3A+journey&template=user_journey.md&title=%28Journey%29+UJ1%3A+Journey+Title) 
template.

For more incremental changes, please open a feature request. Referencing an
[existing User Journey](https://github.com/GoogleCloudPlatform/emblem/issues?q=is%3Aissue+label%3A%22type%3A+journey%22+) 
is helpful in considering how it fits project scope.

The first implementation step for any API change is to send PR to modify the 
OpenAPI description](content-api/openapi.yaml).

### Github workflows automation

All pull requests are subject to the following automated checks where 
applicable:

* *cla/google*: Ensure Google's 
[Contributor License Agreement](#contributor-license-agreement) has been met 
for the proposed change.
* *[header-check](https://github.com/googleapis/repo-automation-bots/tree/master/packages/header-checker-lint)*: 
Ensure all applicable files have copyright headers.
* *[style-terraform](/.github/workflows/style-terraform.yml)*: Runs `terraform 
fmt` on all Terraform configuration.
* *[style-python](/.github/workflows/style-python.yml)*: Runs `black` on all 
python code.
* *[block-merge](/.github/workflows/block-merge.yml)*: Blocks merging PRs that
  have the `do not merge` label, or a label containing the word "`needs`".
* *[auto-label](/.github/workflows/auto-label.yml)*: Adds PR labels based on
  PR title and changed files

