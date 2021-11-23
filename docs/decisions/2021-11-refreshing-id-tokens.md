# Centralized Documentation

* **Status:** draft
* **Last Updated:** 2021-11-23
* **Objective:** Determine how to refresh *id tokens*
## Context & Problem Statement

The *id tokens* used to prove that API calls are being made on behalf of a
specific user expire no more than one hour after they are issued. We want to
allow users to have sessions lasting more than one hour without being forced
to log back in. To do that we must refresh an *id token* when (or before) it
expires.

## Priorities & Constraints

The website should be able to maintain an active *id token* for a logged-in
user for as long as that user remains active on the site. 

## Considered Options

The *Google sign-in for web servers* solution chosen for authentication at
login can provide a long-lived *refresh token* when it first provides an
*id token* to the website. The website can use that token to refresh a new
*id token* until the *refresh token* is revoked by the website or by the user.
Depending on organzation policies for the user's account, the *refresh token*
may expire after a specified extended period.

The website needs to access the *id token* and potentially this *refresh token*
on each request from the logged-in user's browser. The server will set a cookie
in the browser that will allow this information to be retrieved.

Options:

1. The value of the cookie will include the two tokens, possibly encrypted.
2. The value of the cookie will be a randomly generated identifier that can
   be used to fetch the two tokens that have been stored server-side.

## Decision

The website will store this *refresh token* and other session data server-side
to prevent its exposure to the browser.

We have provisionally decided to use Cloud Storage as the server-side data
repository, with objects whose names are the randomly generated identifier for
the cookie, and whose contents are the JSON encoded session data.

## Links

* https://github.com/GoogleCloudPlatform/emblem/pull/210
