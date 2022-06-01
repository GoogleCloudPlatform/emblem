# Automate Dependency Updates

* **Status:** approved
* **Last Updated:** 2022-06-01
* **Objective:** Keep up with dependency updates for a stable & secure project.

## Context & Problem Statement

We have not consistently updated our dependencies across the duration of the project. Manual action to do updates does not work. We have test coverage, so a PR performing an update can be somewhat trusted to catch significant problems with an update.

## Considered Options

* Option 1: Adopt [Renovate Bot](https://docs.renovatebot.com/) to scan our repo and send PRs for updates
* Option 2: Put together a calendar rotation update chores
* Option 3: Write a GitHub action that at least scans for updates and opens issues

## Decision

Chosen option [Option 1: Adopt Renovate] because it handles github actions, Dockerfiles, and the other programming languages we use. It is a popular tool across many projects the team works on.

Option 3 would not have been as comprehensive across types of dependencies, and it would likely have had scope creep.
