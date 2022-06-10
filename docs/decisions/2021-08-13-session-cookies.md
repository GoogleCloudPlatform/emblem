# Use cookies to store tokens minted by Cloud Identity Platform

* **Status:** approved
* **Last Updated:** 2021-08-13
* **Builds on:** [Cloud Identity Platform for SSO](2021-08-13-session-cookies.md)
* **Objective:** How to persist credentials across requests?

Some calls to the API itself require a token that authenticates the current user. Since these calls
are performed _server-side_, we have to forward tokens (generated _client-side_) to the server.

## Rationale

Because our app is rendered serverside using an HTML-based templating language (`jinja2`),
any token-forwarding method we use must work with `GET` requests made by links (HTML `<a>` elements).

This disqualifies things like `POST` requests or [custom HTTP headers](https://stackoverflow.com/questions/3047711/custom-http-request-headers-in-html) to some extent, as both
do **not** work with standard HTML `<a>` elements and would require additional (and arguably non-idiomatic/hacky) frontend Javascript
to forward the token to the server.

Another alternative would have been to switch to a single-page app that calls backend APIs directly,
but that would have required a labor-intensive migration of all of our (`Jinja2`-based) views to frontend Javascript.

Finally, the Firebase documentation [explains how to create](https://firebase.google.com/docs/auth/admin/manage-cookies#create_session_cookie)
session cookies. The fact that this example is present in the official documentation implies
that this is a conceptually valid way of storing user authentication materials.

In our view, storing the token in a cookie was the cleanest solution
available for this problem - which is why we chose it.

## Revision Criteria

If a more straightforward and/or more secure method of storing these tokens becomes available
(either at the Firebase level, or the HTTP-specification level), we may consider migrating to that option.

(For example, we could do away with the `session` cookie if the Firebase client SDK somehow automatically forwarded a generated ID token to the backend with every request.)
