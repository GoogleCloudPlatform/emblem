# Authentication and Authorization for Emblem

The Emblem application authorizes operations on data based
on the user's identity, represented as an email address. Unauthenticated users
(those who have not logged in to the application) have the ability to view
public information such as current campaigns, but cannot view data linked to
a specific user (such as donations), and cannot enter or change any data in
the application.

Authenticated users (logged-in users) have more access, which often depends on
the relationship of the data to display or change with the user's identity. For
example, most users can only view their own donations, but campaign managers
can view every donation to their campaign.

There are two major parts to the application: the API, which manages all
operations on Emblem data, and the website, which provides the user interface.
The website handles authenticating users, and provides proof of that
authentication to the API, which handles deciding which operations to allow
and prohibit.

## Authentication from the inside out

All operations on application data are performed by the API, and the API
is where decisions on whether or not to perform requested operations, or how
to perform them, are made. For this to happen the API needs to know who the
actual user requesting operations is. Our design has chosen for the API to *not* accept
the website's assertion of the user's identity. This creates a smaller secure
zone and also allows other applications, or helper applications, to use the
API as well.

API requests are made via secure HTTP requests, and are authenticated, if they
are authenticated, with an HTTP Authorization header. That header includes
an *id token*, a [JSON Web Token](https://en.wikipedia.org/wiki/JSON_Web_Token)
that contains claims about the user's identity, a validity period, and a digital
signature from a trusted identity verification agent.

We have chosen to use [Google Identity OAuth2](https://developers.google.com/identity/protocols/oauth2/web-server)
as Emblem's identity provider. It is the responsibility of the Emblem website
to take users through that authentication flow to get a valid _id token_,
and then provide it to the API whenever operations on data are needed.

## How to authenticate with Google

Emblem uses [OAuth2 with Google Identity](https://developers.google.com/identity/protocols/oauth2/web-server)
for user authentication. The website performs the authentication flow, acquiring
an *id token* for the authenticated user. That *id token* is included in the
*Authorization* header for every authenticate API call made by the website.

The authentication flow, in a nutshell:

1. User clicks a link in the Emblem website to log in.

1. The website responds with with an HTTP redirect to a Google authentication
server. The request includes several query parameters providing information
about the application making the request.

1. The user's browser makes the indicated request to the authentication server.

1. The authentication server asks the user to sign in to Google and give
permission to provide the user's identity to the Emblem application.

1. Once the user has completed the authentication flow with Google, the
authentication server replies with an HTTP redirect back to an Emblem callback
URL, including a *code* in a query parameter.

1. The user's browser makes the indicated request to the Emblem callback URL.

1. The Emblem website server receives the request, and makes a server-side request
(*not* involving the browser) to the authentication server providing the *code*
and a *client secret* registered with the Emblem website's GCP project.
The authentication server responds with a JSON object that includes an active
*id token*.

1. The Emblem website server sends an HTTP redirect to the user's browser to
return to the website page they started this login flow from. The redirect
also sets a session cookie that references the *id token*.

1. Further requests from the user to the Emblem website include that cookie,
which the website uses to get the *id token*. The website then provides that *id token*
with each API request.

This flow is perhaps as simple as third-party authentication can be, and has
been reliable. It requires registering *the callback URL* with
the Google Cloud project, and acquiring a *client ID* and *client secret* from
the same project.

## How to associate the *id token* with a user session

A session is established when a user logs in by having the website create a
cookie in the user's browser. The cookie has no *Expires* value, which causes
it to be deleted when the browser is closed. It is marked as *Secure* (must
only be sent over the network via HTTPS), *HttpOnly* (inaccessible to
JavaScript), and *SameSite=Strict* (which prevents sending it to other sites,
such as when loading images, and mitigates cross-site request forgery
risk).

This cookie must be associated with the *id token*. We considered these alternatives:

1. Make the value of the cookie the *id token* itself.

1. Encrypt the *id token* with a key known to the server, and make that
encrypted value the value of the cookie.

1. Create a random value for the cookie, save the *id token* and any other
session information server-side, keyed by that random value.

Option 1 is by far the easiest, but requires the *id token* to be exposed to
the user's browser. The *id token* provides access to the API without having
to go through the website as a gatekeeper, so this is a potential problem.
Though, since the *id token* has a very limited lifetime, this option may be
acceptible. After all, the cookie is transmitted only via HTTPS and is only
available to JavaScript in website pages. But it would still be visible to
users via web browser developer tools

Option 2 alleviates some of the concerns with option 1, by encrypting the value
of the cookie, and the Flask framework offers a tool to do that. We tries this
out during development, but further investigation showed that Flask's secret
session cookies we actually only obfuscated. They are digitally signed, which
prevents user-tampering, but they don't actually protect the value of cookie from
discovery by the user. The documentation we found of this is several years old,
but we found nothing indicating that this has changed since then.

That has left us with Option 3, which is a very common choice. A random value
will be chosen as the cookie value, and any information needed to identify the
user, such as the *id token*, will be stored server-side, findable with that
random value.

That leaves us with a problem, though. We cannot store this information in
server memory or filesystem, because the serverless platform does not retain
that state from request to request. And given our serverless architecture, we
prefer a storage solution that scales up and down as our compute platforms
do. Cloud Firestore, in Native or Datastore mode, delivers on this preference,
as does Cloud Storage.

By default, all Firestore access in a Google Cloud project applies to
all collections in the database. Since the website and API applications may
be in the same project, if both were given Firestore access they would each
have access to the other application's data. In turn, that would give the
website access to underlying API data, bypassing API access rules. For that
reason, we have chosen to use Cloud Storage for session data instead of Cloud
Firestore. Early usage has shown the performance of that approach to be
acceptable.


## Refreshing the *id token* that expires in no more than 1 hour

The approaches described above would all acquire an *id token* at user login and
then use that token to make API calls. Unfortunately, the longest duration a
Google sign-in token can have is 60 minutes. So relying on the *id token* from
the login would lead to the website having to force users to log in again
every hour, even if they have been continually interacting with the website
over that time. This would work but would likely alienate users.

Google Identity offers a solution however: a *refresh token*. When a user
logs in, step 2 of the authentication flow previously described can include
two query parameters: *access_type=offline* and *prompt=consent*. When used
together with other required parameters, in return for the *code* sent to
the service in step 7 the website will be provided not only the *id token*
but also a *refresh token*. The *refresh token* is long-lived (possibly
eternally, but can be limited by user and organization policies) and can be
traded for new *id token* at any time. Each new *id token* is active for an
hour, allowing the application to extend a user session without logging in again.

More detail about using and revoking refresh tokens is available at [Refreshing
an access token (offline access)](https://developers.google.com/identity/protocols/oauth2/web-server#offline).

### Where is that *refresh token*?

Based on our understanding of the documentation, we exprected to receive a
refresh token upon user login when setting *access_type=offline*. That
documentation seemed to be incorrect, with no way to get the *refresh token*
we need. A search of [Stackoverflow](https://stackoverflow.com/) revealed this
to be a common problem, and
[one answer](https://stackoverflow.com/questions/10827920/not-receiving-google-oauth-refresh-token)
explained what was happening. The server will *only* return a refresh token the
first time it authenticates a user for a specific application. The user could
revoke the token in their Google account forcing a new refresh token to be
returned on the next login, but that required user intervention would not work for Emblem.

Going back to the original documentation we see this behavior is stated, but we
misunderstood "the initial request to Google's authorization server" to mean
the first request in a user session, when it actually means the first request ever for
that application.

StackOverflow answers indicated that a new refresh token could be forced by
setting *prompt=consent* in step 2. The
[documentation](https://developers.google.com/identity/protocols/oauth2/web-server#httprest_3)
appears to allude to that, though not explicitly. In any case, experimentation
shows that this works, and has been adopted for Emblem.

## Revoking a *refresh token*

We apparently can keep and use a *refresh token* indefinitely, but should we?
We can revoke a *refresh token* we have access to. We revoke the
*refresh token* when the user explicitly logs out, and we expect to revoke it
after some period of unuse, but have not decided exactly when or how to do that
yet.
