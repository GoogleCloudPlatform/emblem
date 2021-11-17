# Centralized Documentation

* **Status:** approved
* **Last Updated:** 2021-11-16
* **Builds on:** [Monorepo](2021-05-monorepo.md)
* **Objective:** Determine how documentation will be organized

## Context & Problem Statement

In our monorepo, documentation lives at the repository root, the docs/ directory, and inside individual "component directories" of the project. This makes it difficult to know where to go to find or improve information.

## Priorities & Constraints <!-- optional -->

* Support documentation-only contributors
* Allow for a future static site of project documentation
* Documentation should not trigger code-only pipelines

## Considered Options

* Option 1: Distributed
  * docs/ provides a landing page
  * content is otherwise distributed whenever possible
  * Each directory is "self-sufficient" for specialists
* Option 2: Centralized
  * docs/ has almost all technical content
  * Top-level directories contain minimal context-setting READMEs

## Decision

Chosen option [Option 2: Centralized]

Centralized documentation means someone can dive into the docs directory and review all the materials, using the file list itself as a table of contents if they choose.

By siloing most of the materials in one place, we're set to refactor towards building a static site.

By minimizing documentation in code directories, we don't need to fine-tune the build pipelines as much to avoid unneeded builds related to documentation changes.

## Links

* https://github.com/GoogleCloudPlatform/emblem/pull/243
