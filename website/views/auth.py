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

""" Website UX for user authentication.

    Handle user login flow via Google Sign-in.

    Requests handled:

        /login - directs user to Google sign-in page.
        /callback - successful login to Google sign-in page causes a redirect
            here. This handler fetches user information and establishes a session
            with that information.
        /logout - deletes the user login session and revokes the long-lived
            refresh token.

    For more information, see https://developers.google.com/identity/protocols/oauth2/web-server
    and related pages for background information on this process.
"""


from flask import (
    Blueprint,
    current_app,
    make_response,
    redirect,
    render_template,
    request,
    session,
    after_this_request
)

import requests
from google.oauth2 import id_token
from google.auth.transport import requests as reqs
from middleware.logging import log
from middleware import session


auth_bp = Blueprint("auth", __name__, template_folder="templates")


@auth_bp.route("/login", methods=["GET"])
def login_get():
    """login_get

    Handles requests made to the path /login. This may occur due to a user
    following a link, or other website pages redirecting here.

    The request may include a query parameter called return_to, which will lead
    to the user being directed to that path following a successful login. This
    path is relative to the application's root URL and special characters must
    be url-encoded.

    Example:

        GET /login?return_to=view_campaign%2F3x87f3
    """

    return_to = request.args.get("return_to", "/")

    # Link to redirect to Google auth service, including required query parameters.
    sign_in_url = "https://accounts.google.com/o/oauth2/v2/auth?"

    # Client apps and their callbacks must be registered and supplied here
    sign_in_url += "redirect_uri={}&".format(current_app.config["REDIRECT_URI"])
    sign_in_url += "client_id={}&".format(current_app.config["CLIENT_ID"])

    # Asking for user email and any previously granted scopes
    sign_in_url += "scope=openid%20email&"
    sign_in_url += "include_granted_scopes=true&"

    # The next two parameters are essential to get a refresh token
    sign_in_url += "prompt=consent&"
    sign_in_url += "access_type=offline&"

    # Asking for a code that can then be exchanged for user information
    sign_in_url += "response_type=code&"

    # Remember this info and echo it back to me so I'll know what to do next
    sign_in_url += "state={}&".format(return_to)

    return redirect(sign_in_url)


@auth_bp.route("/callback", methods=["GET"])
def handle_callback():
    """handle_callback

    A successful login using Google sign-in will end with the user's browser
    being redirected to this path, providing query parameters can can be used
    to retrieve user information.
    """
    args = request.args.to_dict()

    # After handling login info and session creation, where should the user go?
    redirect_path = args.get("state", "/")

    code = args.get("code")
    if code is None:
        log("No authorization code provided to callback.", severity="CRITICAL")
        return render_template("errors/403.html"), 403

    # Exchange the code for tokens
    r = requests.post(
        "https://oauth2.googleapis.com/token",
        data={
            "code": code,
            "client_id": current_app.config["CLIENT_ID"],
            "client_secret": current_app.config["CLIENT_SECRET"],
            "redirect_uri": current_app.config["REDIRECT_URI"],
            "grant_type": "authorization_code",
        },
    )

    try:
        resp = r.json()
    except Exception as e:
        log(f"Request has bad OAuth2 id token: {e}", severity="CRITICAL")
        return render_template("errors/403.html"), 403

    token = resp.get("id_token")
    refresh_token = resp.get("refresh_token")

    try:
        info = id_token.verify_oauth2_token(token, reqs.Request())
        if "email" not in info:
            log(
                f"Decoded OAuth2 id token is missing email: {info}", severity="CRITICAL"
            )
            return render_template("errors/403.html"), 403
    except Exception as e:
        log(f"Request has bad OAuth2 id token: {e}", severity="CRITICAL")
        return render_template("errors/403.html"), 403

    session_id = session.create(
        {
            "id_token": token,
            "refresh_token": refresh_token,
            "email": info["email"],
            "expiration": info["exp"],
        }
    )

    if session_id is None:
        log(f"Could not create session", severity="CRITICAL")
        return render_template("errors/403.html"), 403
    else:
        response = redirect(redirect_path)
        response.set_cookie("session_id", value=session_id, secure=True, httponly=True)
        return response


@auth_bp.route("/logout", methods=["GET"])
def logout():
    """logout

    User is logged out.

    Three actions are taken:
        - refresh token is revoked
        - cookie "session_id" is deleted
        - stored session data for "session_id" is deleted
    """

    session_id = request.cookies.get("session_id")
    if session_id is None:
        # Nothing to do if the user doesn't have a session. Send them home.
        log("Logout request from user without a session cookie", severity="INFO")
        return redirect("/")

    session_data = session.read(session_id)
    if session_data is None:
        # This is bad. User has a session cookie, but there's no corresponding
        # session data. Log it and send the user back home.
        log("Logout request but session data does not exist", severity="CRITICAL")
        return redirect("/")

    refresh_token = session_data.get("refresh_token", "")

    # Best effort to revoke the token
    response = requests.post(
        f"https://oauth2.googleapis.com/revoke?token={refresh_token}", data={}
    )
    if response.status_code >= 400:
        log(
            f"Failed to revoke refresh token on logging out. Message is '{response.text}'",
            severity="WARNING",
        )

    # Delete the session data
    session.delete(session_id)

    # Wipe out the session cookie
    response = make_response(render_template("auth/logout.html"), 200)
    response.delete_cookie("session_id")

    return response
