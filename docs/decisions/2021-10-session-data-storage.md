# Session Data Storage

* **Status:** draft
* **Last Updated:** 2021-10
* **Objective:** Maintain session data such as users' identity tokens

## Context & Problem Statement

Website users may or may not be authenticated. Authenticated users have much
greater access to the application. Each new web request must include information
allowing identification of those users.

## Priorities & Constraints

The necessary information for an authenticated user consists of a short-lived
ID token and a long-lived refresh token. If the ID token is exposed, it can
be used to access Emblem. If the refresh token is exposed, it can be used along
with Google Cloud credentials to get a new ID token.

This information should be kept secure, even from the user it refers to.

## Considered Options

There have been several ways used for providing identification with each
web request:

1.  HTTP Basic Authentication. The web browser requests a username and password
    from the user, maintains it in browser memory, and includes it in a header
    with each request.

2.  Session information in URL. The application is written so that all links
    include information about the user. This may be identification of the user
    or, more commonly, an opaque unique identifier that the server can use to
    retrieve that data.

3.  Session information in a cookie. Similar to the above, but instead of having
    any information or identifiers placed in the URLs, the browser stores them
    in a browser-side cookie and provides the value of the cookie in a header
    with each request.

Basic authentication is limited, has severe security issues, and is not compatible
with third-party authentication providers, such as OAuth2 providers.

Options 2 and 3 each have two variants, one where the identifying information is
stored in the browser, and one where only an opaque unique identifier is
stored in the browser. It is more secure to maintain the actual identifying
information in one place only - the server, rather than in both the browser and
the server.

Option 3 (cookies) is easier to implement than option 2, which would require
rewriting all URLs and make bookmarking nearly impossible, and more secure
since the URLs for option 2 may be logged, including in intermediate proxy servers.

Using either option 2 or 3 with opaque identifiers require storing them in
the web server, or a storage service available to the web server. Possible
solutions include:

* Server memory or storage. This would require having only one web server,
  running on a stateful platform.

* External data storage: Cloud Datastore, Cloud Firestore, or Cloud SQL.

* External blob storage: Cloud Storage.

* External file storage: Filestore

* External memory cache: Memorystore

## Decision

Chosen option: Cookies with an opaque identifier, with the identifier a key
to identifying information in Cloud Storage.

We can't use server-based memory or storage as the web server platform is
Cloud Run, which is stateless. Cloud SQL and Filestore are all instance-based,
unlike the rest of the Emblem application, as is Memorystore at present. We
chose to eliminate instance-based options, leave Firestore, Firestore in
Datastore mode, or Cloud Storage.

At present, Datastore/Firestore have at most one store per project. Since
the Emblem API server uses Firestore, there could be data collisions or
administrative access challenges with them. Solving them would require coordination
between website and API server tiers, which we are keeping separate when
possible.

Cloud Storage allows multiple buckets, each with its own access policies, and
therefore meets our needs best, for now.

*Provisional Decision*

The module is written in such a way
that the implementation can be changed at any time with no effect on the rest
of the website code. It may be that the cost or performance of Cloud Storage
for this use will outweigh the issues with Datastore/Firestore. Experience in
Alpha will dictate whether to investigate a change.
