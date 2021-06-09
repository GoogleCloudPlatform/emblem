# Maintainers Guide

This README lays out maintenance practices for this project.

## Reviewing Pull Requests

This repository is configured to require at least one review approver.

However, not everyone with approval has the same skills.

If you do not feel your approval is sufficient to support merging a PR, please state what kind of review follow-up is needed.

Consider using the review feedback guidance at [Conventional Comments](https://conventionalcomments.org) to reduce ambiguity.

## Managing Requirements

We manage project requirements as issues of the "User Journey" type. Once a User Journey is accepted, it is a permanent fixture in the project.

* Requirements will be edited into the Journey issue description.
* New requiments may be added in future iterations to build out related functionality.
* If any requirements are unmet, the journey is open. If all requirements are met it is closed.

Our top priority for automated testing is end-to-end tests that prove user journey requirements are met. If those tests fail the user journey should be (re-)opened.

Be generous in reference user journeys from other issues and PRs. One of the roles of the User Journey is to serve as a landing page for learners to explore what was involved in satisfying a requirement.
