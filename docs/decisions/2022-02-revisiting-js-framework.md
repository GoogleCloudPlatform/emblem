# Revisiting & proposing JS Frameworks

* **Status:** [approved]
* **Last Updated:** 2022-02-03
* **Builds on:** [Avoid frontend JS frameworks](2021-03-avoid-js-frameworks.md)
* **Objective:** New frontend strategy moving forward

## Context & Problem Statement

In order to make contributing to the web application easier and the introduction of new application features,
the team has re-visited the opportunity to add in a JS framework.

## Priorities & Constraints

* Speed of UI development
* Complexity of some of the features in the mock
* Ease of in-house, as well as external community contributors

## Considered Options

* Option 1: React
* Option 2: LitElement (lit.dev)

## Decision

Chosen option [Option 2: LitElement]

The team has ultimately chosen LitElement over React after quick dive, due to the approachability of the JS framework compared to React.
Additionally, the future opportunity to work with the web components team was a great plus.

### Expected Consequences

Learning curve
* Dedicated group of engineers will need to get up to speed with LitElement and the other JS trappings

Current Emblem architecture will need to accomodate the new web application in the following ways:
* Current authentication flow will need to be refactored (currently left in flask app)
* Current decision of leaving the flask app as a proxy to the api is still pending
* Containerizing the new web app will need to be revisited (w/ or w/o flask app tbd)




