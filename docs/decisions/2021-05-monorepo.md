# Monorepo for Code Management

* **Status:** approved
* **Last Updated:** 2021-05
* **Objective:** [description or link to contextual issue]

## Context & Problem Statement

How will we host code and facilitate contribution workflows?

## Priorities & Constraints <!-- optional -->

* We have at least two primary services with supporting facilities
* We need to fit our repositories into an existing GitHub organization

## Considered Options

* Monorepo: A single repository where some of the folders contain decoupled services.
* Multi-repo: Multiple repositories, orchestrated together by a build process to produce an operating system.

## Decision

Chosen option: Monorepo

This will keep discoverability, maintainability, and end-to-end contributions manageable.

### Expected Consequences <!-- optional -->

* Additional complexity in pipeline configuration
* Inreased risk of "decoupled monolith" anti-pattern
* Will not explore multi-repository management challenges which many organizations face
