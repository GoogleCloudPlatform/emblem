# Create a service account for testing

* **Status:** approved
* **Last Updated:** 2021-09
* **Objective:** Provide user identity for API testing

## Context & Problem Statement

The API has both unauthenticated and authenticated resources. How do we provide an identity for authenticated or user-dynamic resources?

## Priorities & Constraints <!-- optional -->

* Tests are driven by Cloud Build, but Cloud Build does not provide a standard Service Identity

## Decision

Create a service account that can be used by the Cloud Build pipelines. Authenticate that service account by providing an identity token to the test code to be injected into requests as needed.

The service account should have as few privileges as possible (ideally, none). It will be used to create ID tokens during test runs. The only thing that will matter for those test runs is the identity provided in the token, not any privileges it has.

Test runs will add the service account's email address as an approver or a campaign manager as needed for the tests to determine that the API is enforcing authorization property.

The service account should not be used in a production deployment, even though the tokens generated for it expire in no more than an hour.

### Further Rationale

The API handler uses standard Google authentication libraries to decode and validate the provided ID token. Those libraries require an ID token created by Google, and check their expiration times. Any IAM account can have an ID token provided to it, and we would not want to create a dummy user account for this purpose. Hence, the decision to use a service account.

### Revisiting this Decision <!-- optional -->

If Cloud Build adds direct support for identity token generation, we will keep the service account but evaluate removing ID Token pre-creation.

## Links

* https://github.com/GoogleCloudPlatform/emblem/pull/151
* https://github.com/GoogleCloudPlatform/emblem/pull/161
