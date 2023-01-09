# Keep generated client libraries in GitHub repository

- Status: proposed
- Last updated: 2022-01
- Objective: Decide whether to generate client libs on each deploy or not

## Context & Problem Statement

The Emblem API client libraries are generated from the Open API spec for the
API. These generated client libraries have been kept in GitHub rather than
requiring them to be regenerated on every Emblem deployment.

The question now is whether to continue this, or require deployments to
generate the client libraries themselves.

## Priorities & Constraints


## Considered Options

1. Leave things as they are. When the API spec is updated, the person updating
   it also generates a new client library and checks that in with the same PR.
2. Option 1, but also change the website's `requirements.txt` to point to the
   client libraries' canonical GitHub URL instead of a directory relative to
   the `requirements.txt` location. This would permit deployment of the website
   without fetching the entire GitHub repository.
3. Remove the client libraries from GitHub and have the application deployment
   process generate them on each deployment.

Note that option 3 requires having the OpenAPI code generator and necessary
environment to deploy, which options 1 or 2 require the developer of the API
spec to have that.

## Decision

We will do Option 2. We have been using Option 1 up until now, and the only
issue we have found is the need to copy the client libraries upon deploy.

### Expected Consequences

None.

### Revision Criteria

There are concerns that this might cause the libraries and the API to get out
of sync. If that happens, we will revisit and possibly revise this decision.
