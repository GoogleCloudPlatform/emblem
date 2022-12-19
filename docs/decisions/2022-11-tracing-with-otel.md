# Tracing with Open Telemetry

* **Status:** proposed
* **Last Updated:** 2022-11-22
* **Objective:** Provide working example of tracing telemetry with multi-service
  architecture.

## Context & Problem Statement

Observability (specifically Tracing) is a rapidly-evolving space,
with many competing solutions. Before we begin instrumenting, we will decide on
a single toolchain to use throughout Emblem. Ideally the same tools can be used
for Metrics as well.

## Priorities & Constraints <!-- optional -->

* Stable language support for both Javascript and Python
* Support for multiple trace backends, since the space continues to evolve
* Extensible with additional spans/events as needed
* An ideal solution would include a metrics library as well

## Considered Options

* Option 1: [OpenCensus](http://opencensus.io)
    * Absorbed into OpenTelemetry, with deprecation coming soon. Any OC work
      would have to be rewritten in roughly 2 years or less
* Option 2: [Cloud Tracing library](https://pypi.org/project/google-cloud-trace/)
    * Supports only Cloud Trace, and has no option for metrics, though there is
      a [suite of related
      apis](https://cloud.google.com/python/docs/stackdriver)
* Option 3: [OpenTelemetry](http://opentemeletry.io)
    * Stable support for Python and Javascript
    * Flexible backend support, including Cloud Trace
    * Easily extensible with additional trace details

## Decision

Chosen option [Option 3: OpenTelemetry]

OpenTelemetry meets all of our current criteria, and has considerable
community engagement. Library support for the languages in question is stable
for both Tracing and Metrics.

OTel's trace propagation uses the W3C-standard `traceparent` header, which
allows for trace spans from GCP components, like Load Balancers, when using a
Cloud Trace backend.

### Expected Consequences <!-- optional -->

* Additional Dependency: Cloud Trace

### Revisiting this Decision <!-- optional -->

* If industry attention or community involvement shifts away from OpenTelemetry,
  it would be worth investigating the new alternative and at least adding some
  further Research links to this decision record.

### Research <!-- optional -->

* [Jaeger](jaegertracing.io), like OpenCensus, is retiring their instrumentation
  clients in favor of OTel.

## Links

* Related PRs
* Related User Journeys
