# Store optional Emblem features in "extension" directories
 
* **Status:** approved
* **Last Updated:** 2022-08
* **Objective:** figure out where to put code/resources for Emblem's optional "add-on" features

## Context & Problem Statement

Some of Emblem's features are important for some of Emblem's target audiences, but may not be of interest to _all_ of them.

Thus, the Emblem team needed a way for interested audiences to enable these features on a voluntary, "opt-in" basis.

## Priorities & Constraints

- **Easy Configuration**: affected features should be easy to opt into. _(Note that "retroactive opt-outs" - i.e. making opt-ins reversible - is not a priority.)
- **Separation of Concerns:** our team wanted to keep the implementations for opt-in and required features separate.
- **Minimize Duplication:** our team wanted

## Considered Options

### Extension Model
Our first option was to use a "extension" model, where Emblem's opt-in features were stored separately from core Emblem functionality.

We also planned to store each opt-in feature separately from the other opt-in features to allow Emblem users to opt into individual features one-by-one.

### Feature Flags

Our second option was to store opt-in features and core features in the same folder structure. Emblem end-users could then use _feature flags_ to enable or disable optional features.

## Decision

Chosen option: **Extension Model**

The Emblem team chose to use the **Extension Model** for two reasons:

> The Extension Model enabled greater separation of concerns vs. the Feature Flags approach. This enables Emblem contributors to make changes to the project without having to worry about 
>
> While the Extension Model _does_ complicate Emblem's end-user setup process slightly, the additional complication is greatly outweighed by the separation-of-concerns benefits described above. 

## Links

* [Example Extension](/installation-testing) (Installation Testing)
* [Discussion Thread in related PR](https://github.com/GoogleCloudPlatform/emblem/pull/490#discussion_r890645862)
