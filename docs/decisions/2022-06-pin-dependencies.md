# Pin App dependencies

* **Status:** approved
* **Last Updated:** 2022-06-01
* **Builds on:** [2022-06 Automate Dependency Updates](2022-06-automate-dependencies.md)
* **Objective:** Secure our supply chain by pinning dependencies

## Context & Problem Statement

In order to secure our software supply chain, dependencies should be specifically
versioned. This would help Emblem towards slsa.dev compliance on [Hermetic and Reproducible builds](https://slsa.dev/spec/v0.1/requirements#hermetic).

## Priorities & Constraints <!-- optional -->

* App should be pinned if we want to manage it securely
* Client Library is generated, but we don't regularly regenerate it
* Experimental directory should be more fluid to support research
* Renovate offers a [rangeStragegy setting](https://docs.renovatebot.com/configuration-options/#rangestrategy) that can be configured by directory

## Considered Options

* Option 1: Use renovate `rangeStrategy: auto`
* Option 2: Use renovate `rangeStrategy: pin`
* Option 3: Use an approach based on where in the monorepo the update happens. For example:  `rangeStrategy: pin` on app, `rangeStrategy: bump` in experimental, and  `rangeStrategy: replace` on Client Library

## Decision

Chosen option [Option 3: Mixed approach].

We will `pin` the main app dependencies to ensure more deterministic build process (acknowledging this is just one step in the road).

We will `bump` the experimental dependencies, to ensure when experiments land the baseline dependencies are as forward-looking as possible.

We will `replace` library dependencies, to ensure dependencies are updated but remain flexible for the app (or possibly other packages) to use them.
