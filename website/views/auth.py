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


import datetime
import os
import time

import firebase_admin

from firebase_admin import auth, exceptions
from flask import (
    abort,
    Blueprint,
    current_app,
    make_response,
    redirect,
    request,
    render_template,
)


auth_bp = Blueprint("auth", __name__, template_folder="templates")
default_app = firebase_admin.initialize_app()


@auth_bp.route("/login", methods=["POST"])
def login_post():
    id_token = request.form["idToken"]
    expires_in = datetime.timedelta(days=5)

    try:
        # Validate ID token
        # See https://firebase.google.com/docs/auth/admin/verify-id-tokens#verify_id_tokens_using_the_firebase_admin_sdk
        decoded_claims = auth.verify_id_token(id_token)
        if time.time() - decoded_claims["auth_time"] > 5 * 60:
            # Only allow sign-ins with tokens generated in the past 5 minutes
            return flask.abort(401, "Token has expired.")

        # Create session cookie
        # See https://firebase.google.com/docs/auth/admin/manage-cookies#python
        session_cookie = auth.create_session_cookie(id_token, expires_in=expires_in)

        # Configure response to store session cookie
        expires = datetime.datetime.now() + expires_in
        response = make_response(redirect("/"))
        response.set_cookie(
            "session", session_cookie, expires=expires, httponly=True, secure=True
        )

        return response
    except auth.InvalidIdTokenError as err:
        print("Invalid ID token", err)
        return abort(401, "Invalid ID token.")
    except exceptions.FirebaseError as err:
        print("Failed to create a session cookie", err)
        return abort(401, "Failed to create a session cookie.")


@auth_bp.route("/login", methods=["GET"])
def login_get():
    if not current_app.config["SHOW_AUTH"]:
        return abort(404, "Login disabled")

    return render_template("auth/login.html")


@auth_bp.route("/logout", methods=["GET"])
def logout():
    response = make_response(redirect("/"))
    response.set_cookie("session", "", expires=0)
    # Clear session token
    response.set_cookie("session", "", expires=0)

    return response
