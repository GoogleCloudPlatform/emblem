# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os
from flask_cors import CORS
from flask import (
    Flask,
    g,
    Blueprint,
    current_app,
    make_response,
    redirect,
    render_template,
    request,
    session,
)

import requests
from google.auth.transport import requests as reqs
from google.oauth2 import id_token
from resources import methods
from middleware import session

resource = [
    "approvers",
    "campaigns",
    "causes",
    "donations",
    "donors",
]

app = Flask(__name__)
cors = CORS(app, resources={r"/*": {"origins": "*"}})
CORS(app)

# Check authentication and remember result in global request context
#
# If authentication is invalid, or operation is unauthorized,
# reject the request with 403 Forbidden. Otherwise, return None,
# and normal processing continues
@app.before_request
def check_user_authentication():
    g.verified_email = None

    auth = request.headers.get("Authorization", None)

    if auth is None:
        return

    if not auth.startswith("Bearer "):
        return

    token = auth[7:]  # Remove "Bearer: " prefix

    # Extract the email address from the token. Since there may be
    # two types of token provided (Firebase or Google OAuth2) and
    # failed verification raises an exception, need multiple
    # try/except blocks.

    info = None
    try:
        info = id_token.verify_firebase_token(token, reqs.Request())
    except ValueError:
        pass

    try:
        if info is None:
            info = id_token.verify_oauth2_token(token, reqs.Request())
    except ValueError:
        pass

    if info is not None:  # Remember the email address throughout this request
        if "email" in info:
            g.verified_email = info["email"]

    return

#############################
# Authentication
# TODO: Ensure any terraform scripts/bash scripts
# update content-api container with
# CLIENT_ID, CLIENT_SECRET, EMBLEM_SESSION_BUCKET, REDIRECT_URI
#############################

@app.route("/callback", methods=["GET"])
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
        return render_template("errors/403.html"), 403

    client_id = os.getenv("CLIENT_ID")
    client_secret = os.getenv("CLIENT_SECRET")
    redirect_uri = os.getenv("REDIRECT_URI")

    # Exchange the code for tokens
    r = requests.post(
        "https://oauth2.googleapis.com/token",
        data={
            "code": code,
            "client_id": client_id,
            "client_secret": client_secret,
            "redirect_uri": redirect_uri,
            "grant_type": "authorization_code",
        },
    )

    try:
        resp = r.json()
    except Exception as e:
        return render_template("errors/403.html"), 403

    token = resp.get("id_token")
    refresh_token = resp.get("refresh_token")

    try:
        info = id_token.verify_oauth2_token(token, reqs.Request())
        if "email" not in info:
            return render_template("errors/403.html"), 403
    except Exception as e:
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
        return render_template("errors/403.html"), 403
    else:
        response = redirect(redirect_path)
        response.set_cookie("session_id", value=session_id, secure=True, httponly=True)
        return response

@app.route("/hasSession", methods=["GET"])
def has_session():
    session_id = request.cookies.get("session_id")

    if session_id is None:
        return "false"

    session_data = session.read(session_id)

    if session_data is None:
        return "false"

    return "true"

@app.route("/logout", methods=["GET"])
def logout():
    """logout

    User is logged out.

    Three actions are taken:
        - refresh token is revoked
        - cookie "session_id" is deleted
        - stored session data for "session_id" is deleted
    """

    redirect_uri = os.getenv("REDIRECT_URI")
    session_id = request.cookies.get("session_id")

    if session_id is None:
        return redirect(redirect_uri)

    session_data = session.read(session_id)
    if session_data is None:
        return redirect(redirect_uri)

    refresh_token = session_data.get("refresh_token", "")

    # Best effort to revoke the token
    response = requests.post(
        f"https://oauth2.googleapis.com/revoke?token={refresh_token}", data={}
    )

    # Delete the session data
    session.delete(session_id)

    # Wipe out the session cookie
    response.delete_cookie("session_id")

    return response

#############################
# Resource collection methods
#############################

@app.route("/<resource_name>", methods=["GET"])
def handle_list(resource_name):
    if resource_name not in resource:
        return "Not found", 404
    return methods.list(resource_name)


@app.route("/<resource_name>/<id>/<subresource_name>", methods=["GET"])
def handle_list_subresource(resource_name, id, subresource_name):
    return methods.list_subresource(resource_name, id, subresource_name)


@app.route("/<resource_name>", methods=["POST"])
def handle_insert(resource_name):
    if resource_name not in resource:
        return "Not found", 404
    if not request.is_json:
        return "Unsupported media type", 415

    body = request.get_json(silent=True)
    if body is None:
        return "Bad request", 400

    return methods.insert(resource_name, body)


#############################
# Individual resource methods
#############################

@app.route("/<resource_name>/<id>", methods=["GET"])
def handle_get(resource_name, id):
    if resource_name not in resource:
        return "Not found", 404
    return methods.get(resource_name, id)


@app.route("/<resource_name>/<id>", methods=["DELETE"])
def handle_delete(resource_name, id):
    if resource_name not in resource:
        return "Not found", 404
    return methods.delete(resource_name, id)


@app.route("/<resource_name>/<id>", methods=["PATCH"])
def handle_patch(resource_name, id):
    if resource_name not in resource:
        return "Not found", 404
    if not request.is_json:
        return "Unsupported media type", 415

    body = request.get_json(silent=True)
    if body is None:
        return "Bad request", 400

    return methods.patch(resource_name, id, body)


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=8080, debug=True)
