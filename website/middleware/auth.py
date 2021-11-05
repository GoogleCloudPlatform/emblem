# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


""" Determine the already logged-in user, refresh tokens if appropriate.

    This module handles checking that a request comes from an authenticated
    user by checking a stored session for a cryptographically signed,
    unexpired id token. It also handles getting a refreshed id token if
    the stored one has expired, and updating the session with it.

    This module does not deal with acquiring an id token and matching refresh
    token and creating a stored session including them. Nor does it address
    revoking tokens when the user logs out. Those are dealt with by the
    website/views/auth.py module.

    See https://developers.google.com/identity/protocols/oauth2/web-server and
    related pages for background information on this process.

    Current limitations:
    - No matter how long it has been since the id_token expired, this module
      will refresh it if the id_token issuer allows it. Rules to limit this
      idle duration and forcing a user to log in again are likely to be added
      in the future.
"""

from datetime import datetime
from flask import g, current_app, request
import requests

from middleware.logging import log
from middleware import session
import emblem_client


# Treat tokens within this many seconds of expiration as already expired
EXPIRATION_MARGIN = 30


def init(app):
    @app.before_request
    def check_user_authentication():
        """check_user_authentication

        Runs before a request is passed to a handler.

        If user is not logged in (no "session_id" cookie or no related session
        data) just create a new EmblemClient with no user token and return.

        Check whether the current request includes a session cookie containing
        an unexpired id_token that will be usable for the expected length
        of the request (EXPIRATION_MARGIN).

        If the cookie exists, but is expired or about to expire, use the
        refresh_token in the cookie to get a new id_token. Set the stored
        session's id_token and expiration values to match the newly fetched
        id_token.

        Create a new EmblemClient object to be used for the duration of
        this request, for accessing the client library.
        """

        API_URL = app.config.get("API_URL")
        log(f"API_URL={API_URL}", severity="DEBUG")

        session_id = request.cookies.get("session_id")
        if session_id is None:
            g.api = emblem_client.EmblemClient(API_URL)
            return

        session_data = session.read(session_id)
        if session_data is None:
            g.api = emblem_client.EmblemClient(API_URL)
            log(f"Missing session data for id {session_id}", severity="ERROR")
            return

        id_token = session_data.get("id_token")
        expiration = session_data.get("expiration")

        if (
            expiration is not None
            and expiration - datetime.timestamp(datetime.now()) < EXPIRATION_MARGIN
        ):
            id_token, expiration = get_refreshed_token(session.get("refresh_token"))

            session_data["id_token"] = id_token
            session_data["expiration"] = expiration

            session.update(session_id, session_data)

        g.api = emblem_client.EmblemClient(API_URL, access_token=id_token)


def get_refreshed_token(refresh_token):
    """get_refreshed_token(refresh_token)

    Args:
        refresh_token (str): the refresh token provided by Google sign-in when
            the user most recently logged in.

    Returns:
        A current ID token and its expiration (as a Unix timestamp).
        Returns None, None if refreshing fails.
    """
    if refresh_token is None:
        log("Refresh token request is missing the token")
        return None, None

    try:
        response = requests.post(
            "https://oauth2.googleapis.com/token",
            {
                "client_id": current_app.config["CLIENT_ID"],
                "client_secret": current_app.config["CLIENT_SECRET"],
                "refresh_token": refresh_token,
                "grant_type": "refresh_token",
            },
        )
    except Exception as e:
        log(f"Request to token server failed: {e}", severity="ERROR")
        return None, None

    try:
        updates = response.json()
    except Exception as e:
        log(
            f"ERROR: exception {e} when parsing refresh token response {response.text}.",
            severity="ERROR",
        )
        return None, None

    id_token = updates.get("id_token")
    expiration = datetime.timestamp(datetime.now()) + updates.get("expires_in")

    return id_token, expiration
