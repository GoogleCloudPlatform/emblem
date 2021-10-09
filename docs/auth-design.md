# Authentication and Authorization for Emblem

The Emblem application permits and prohibits operations on giving data based
on the user's identity, represented as an email address. Unauthenticated users
(those who have not logged in to the application) have the ability to view
public information, such as current campaigns, but cannot view data linked to
a specific user (such as donations), and cannot enter or change any data in
the application.

Authenticated users (logged-in users) have more access, which often depends on
the relationship of the data to display or change with the user's identity. For
example, most users can only view their own donations; authenticated users can
create new donations, which will be linked to their identity.

There are two major parts to the application: the API, which manages all
operations on Emblem data, and the website, which provides the user interface.
The website handles authenticating users, and provides proof of that
authentication to the API, which handles deciding which operations to allow
and prohibit.

## Authentication from the inside out

All operations on application data are performed by the API, and the API
is where decisions on whether or not to perform requested operations, or how
to perform them, are made. For this to happen, the API needs to know who the
actual user requesting operations is. Our design has chosen for the API to *not* accept
the website's assertion of the user's identity. This creates a smaller secure
zone, and also allows other applications, or helper applications, to use the
API as well.

API requests are made via secure HTTP requests, and are authenticated, if they
are authenticated, with an HTTP Authorization header. That header includes
an *id token*, a JWT that contains claims about the user's identity, a validity
period, and a digital signature from a trusted identity verification agent.

We have chosen to use [Google Identity Oauth2](https://developers.google.com/identity/protocols/oauth2/web-server)
as Emblem's identity provider. It is the responsibility of the Emblem website
to take user's through that authentication flow to get a valid _id token_,
and then provide it to the API whenever access to data is needed.

## First decision: how to authenticate with Google

There are many way to authenticate with Google, or with other identity providers
that may be federated with a Google identity service. We initially decided to
use [Firebase authentication using Google Sign-in with
JavaScript](https://firebase.google.com/docs/auth/web/google-signin).

After using Firebase authentication for a short while, we decided it was not
a good fit for our needs. It required setting up a Firebase project as well
as a Google Cloud project, and required three Emblem codebases to be involved
(website browser-based code, website server-side code, and API server-side code).
These combined to make setting up new Emblem instances more complicated and
more prone to failures when done manually.

The project then pivoted to using [OAuth2 with Google
Identity](https://developers.google.com/identity/protocols/oauth2/web-server),
which is the current solution. This approach involved only the two server-side
codebases (website and API) and allows parts of the authentication flow to be
more easily isolated and examined in detail, for debugging.

The current authentication flow, in a nutshell:

1. User clicks a link or presses a button in the Emblem website to log in.

1. The website responds with with an HTTP redirect to a Google authentication
server, which includes several values included as query parameters.

1. The user's browser makes the indicated request to the authentication server.

1. The authentication server asks the user to sign in to Google and give
permission to provide the user's identity to the Emblem application.

1. Once the user has completed the authentication flow with Google, the
authentication server replies with an HTTP redirect back to an Emblem callback
URL, including a *code* in a query parameter.

1. The user's browser makes the indicated request to the Emblem callback URL.

1. The Emblem server receives the request, and makes a server-side request
(*not* involving the browser) to the authentication server providing the *code*
and a *client secret* registered with the Emblem project website. The authentication
server responds with a JSON object that includes an active *id token*.

1. The Emblem website server sends an HTTP redirect to the user's browser to
return to the website page they started this login flow from. The redirect
also includes a session cookie that references the *id token*.

1. Further requests from the user to the Emblem website include that cookie,
which the website uses to get the *id token*, and then provides that *id token*
with each API request.

This flow is perhaps as simple as third-party authentication can be, and is
expected to be reliable. It requires registering *the callback URL* with
the Google Cloud project, and acquiring a *client ID* and *client secret* from
the same project.

## Second decision: how to associate the *id token* with a user session

A session is established when a user logs in by having the website creating a
cookie in the user's browser. The cookie has no *Expires* value, which causes
it to be deleted only when the browser is closed. It is marked as *Secure* (must
only be sent over the network via HTTPS), *HttpOnly* (inaccessible to
JavaScript), and *SameSite=Strict* (which prevents sending it to other sites,
such as when loading images, and only mitigates cross-site request forgery
risk).

This cookie must be associated with the *id token*. We considered alternatives:

1. Create a random value for the cookie, save the *id token* and any other
session information server-side, keyed by that random value.

1. Make the value of the cookie the *id token* itself.

1. Encrypt the *id token* with a key known to the server, and make that
encrypted value the value of the key.

Option 1 above seems to be the most secure choice, but the stateless nature of
the website server would require an external data store. Cloud Firestore might
be a good option, but in some cases the website and API share a project, and
the current nature of Cloud Firestore would mean they would share the same
database. That is possible, but unappealing.

Given the ephemeral nature of an *id token* and the fact that it would be
stored and transferred in fairly secure ways, option 2 could be acceptible. But
we would prefer not to have to do this.

The Flask website framework the website uses makes using encrypted cookies
easy, enabling option 3. We have decided to use that approach, with an eye to
moving to option 1 some time in the future, especially when more server-side
storage options become available.

## Problem: *id token* expires in no more than 1 hour

The approaches described above meet Emblem authentication needs, but require
the user to be forced to log in again every hour, even they have been continually
interacting with the website over that time. This is behavior that could be
tolerable for an application of Emblem's kind, but we found it undersirable.

Google Identity offers a solution however: a *refresh token*. When a user
logs in, step 2 of the authentication flow previously described can include
a query parameter *access_type=offline*, and in return for the *code* sent to
the service in step 7 will be provided not only the *id token* but also a
*refresh token*. The *refresh token* is long-lived (possibly eternally, but
can be limited by user and organization policies) and can be traded for new
*id token* at any time. That new *id token* is active for an hour, allowing
the application to extend a user session without logging in again.

### Where is that *refresh token*?

Despite what we understood from the documentation, we were not receiving one
upon user login when setting *access_type=offline*. The documentation seemed
to be incorrect, with no way to get the *refresh token* we need. A search of
[Stackoverflow](https://stackoverflow.com/) revealed this to be a common
problem, and [one answer](https://stackoverflow.com/questions/10827920/not-receiving-google-oauth-refresh-token)
explained what was happening. The server will only return a refresh token the
first time it authenticates a user for a specific application. The user could
revoke the token in their Google account, but that would not work for Emblem.

Going back to the original documentation, this behavior is stated, but we
misunderstood "the initial request to Google's authorization server" to mean
the first request in a user session, when it means the first request ever for
that application.

StackOverflow answers indicated that a new refresh token could be forced by
setting *prompt=consent* in step 2. The [documentation](https://developers.google.com/identity/protocols/oauth2/web-server#httprest_3)
appears to allude to that, though not explicitly. In any case, experimentation
showed that this worked, and has been adopted for Emblem.

### How to remember the *refresh token*?

Since the *refresh token* does not (or at least may not) expire, it should
not be put in a browser cookie, not matter how protected, even if it is
encrypted. However, server-side storage for the website, as opposed to the API,
is still an open question. We will go with the encrypted cookie option for now,
during early development and demonstration, but we must change that before
any outside use.

Since the *refresh token* being used to get an *id token* requires providing
a server-side *client secret*, this choice is not as bad as it might be.

## Revoking a *refresh token*

We apparently can keep and use a *refresh token* indefinitely, but should we?
We can revoke a *refresh token* we have access to. Our initial design decision
will be to determine whether to do that or not. A likely first step would be
to revoke the *refresh token* when the user explicitly logs out, or when the
*refresh token* has not been used in some still to be decided interval.
