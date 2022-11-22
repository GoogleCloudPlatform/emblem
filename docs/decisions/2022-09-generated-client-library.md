# Generate, rather than hand-write, the Content API client library

* **Status:** proposed
* **Last Updated:** 2022-09
* **Objective:** Explain why we use a generated client library and chose the specific tool

## Context & Problem Statement

The Emblem website is currently a server-side Flask application written in
Python. Requiring all access to application data to be made via the Content API
ensures consistency of enforcing data and application rules. Similarly, rather
than having the Flask application make direct web requests to the Content API
REST API, using a Python client library reduces duplication of code and effort
in the website's code base.

The Python client library could be hand-written or automatically generated from the
[Content API API specification](../../content-api/openapi.yaml).

## Priorities & Constraints

The website code should be maintainable and testable, even by developers who are
not deep experts in the Python programming language.

## Considered Options

### Option 1: Hand-write the library

Given the nature of the REST API, hand writing the library could be fairly easy.
However, routines for working on different entity types and operations would be
very similar, leading to lots of nearly, but not completely, identical code.
More generic code, with adjustments for specific needs, could be used instead,
but this would create a more complicated code base.

### Option 2: Generate the library

Since it had already been decided to use a [REST API](./2021-04-functions-api.md)
and document that API with the [OpenAPI standard](./2021-08-18-openapi-tools.md),
which has a large number of tools available for it, generating the library would
require little effort.

## Decision

We chose to generate the library. Since the generated library supports a number
of options when create a client object, we also created a wrapper module that
creates that object with the options most applicable to the Emblem application.

As [previously documented](./2021-08-17-openapi-tools.md), we tried two
well-known tools and selected the
[OpenAPI generator](https://github.com/OpenAPITools/openapi-generator).
