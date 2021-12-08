# User Authentication

* **Status:** draft
* **Last Updated:** 2021-11-23
* **Objective:** Choose how to authenticate users with Google

## Context & Problem Statement

How should we authenticate users to the Emblem website?

Whatever method we choose must provide the website a way to acquire an OAuth2
*id token* from a trustworthy identity service, in order to provide that for
all authenticated API requests.

## Priorities & Constraints

* We prefer that users can authenticate with credentials they already have,
  such as for a Google account, or Azure AD.
* We do not want the users' credentials to ever be exposed to us.
* Users should be able to keep an authenticated website session active as long
  as they want, provided they are not idle for an extended period.
* Setting up the conditions for using the identity service should reasonably
  easy for organizations setting up their own Emblem applications.

## Considered Options

1. Firebase authentication. JavaScript in the website pages use Firebase
   Authentication to log the user in via Google sign-in or a variety of other
   identity platforms available.
2. Google sign-in for web servers. The website server provides webpages with
   links that take the user through the sign-in flow, and the server
   communicates directly with the Google authentication provider.

## Decision

*Google sign-in for web servers.* This requires code for only two code bases
(the website server code and the API server code) instead of three (those two
plus the website browser code).

We tried Firebase Authentication first, but we found it difficult to provide
the website server with the authentication token needed to use the API, and
hard to debug any problems we found. Our Google sign-in solution has been working
well during previews.

## Links

* [This PR](https://github.com/GoogleCloudPlatform/emblem/pull/210)
* [Oauth2 login and refresh token PR](https://github.com/GoogleCloudPlatform/emblem/pull/212)
