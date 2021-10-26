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


from flask import (
    Blueprint,
    current_app,
    redirect,
    render_template,
    request,
    session,
)
import logging
import requests

from google.oauth2 import id_token
from google.auth.transport import requests as reqs


auth_bp = Blueprint("auth", __name__, template_folder="templates")


@auth_bp.route("/login", methods=["GET"])
def login_get():
    sign_in_url = "https://accounts.google.com/o/oauth2/v2/auth?"
    sign_in_url += "scope=openid%20email&"
    sign_in_url += "access_type=offline&"
    sign_in_url += "include_granted_scopes=true&"
    sign_in_url += "response_type=code&"
    sign_in_url += "prompt=consent&"
    sign_in_url += "state={}&".format("/")  # After sign-in, redirect user to root URL
    sign_in_url += "redirect_uri={}&".format(current_app.config["REDIRECT_URI"])
    sign_in_url += "client_id={}&".format(current_app.config["CLIENT_ID"])

    return redirect(sign_in_url)


@auth_bp.route("/callback", methods=["GET"])
def handle_callback():
    args = request.args.to_dict()
    redirect_path = args["state"]
    code = args["code"]

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
        logging.warning("Request has bad OAuth2 id token: {}".format(e))
        return render_template("error.html"), 403

    token = resp.get("id_token")
    refresh_token = resp.get("refresh_token")

    try:
        info = id_token.verify_oauth2_token(token, reqs.Request())
        if "email" not in info:
            return render_template("error.html"), 403
        session["email"] = info.get("email")
    except Exception as e:
        logging.warning("Request has bad OAuth2 id token: {}".format(e))
        return render_template("error.html"), 403

    session["id_token"] = token
    session["refresh_token"] = refresh_token
    session["email"] = info["email"]
    session["expiration"] = info["exp"]

    return redirect(redirect_path)


@auth_bp.route("/logout", methods=["GET"])
def logout():
    # Revoke the refresh token, then wipe out the session cookie

    refresh_token = session.get("refresh_token")

    # Best effort to revoke the token
    response = requests.post(
        f"https://oauth2.googleapis.com/revoke?token={refresh_token}",
        data = {}
        )
    print(f"DEBUG - revoke token response: {response.text}")
    if response.status_code >= 400:
        logging.warning(
            f"Failed to revoke refresh token on logging out. Message is '{response.text}'"
        )

    # Wipe out the session cookie
    for key in [k for k in session]:
        del session[key]

    return render_template("auth/logout.html")
