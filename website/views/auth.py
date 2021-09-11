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
    try:
        # Validate ID token
        # See https://firebase.google.com/docs/auth/admin/verify-id-tokens#verify_id_tokens_using_the_firebase_admin_sdk
        id_token = request.form["idToken"]
        decoded_claims = auth.verify_id_token(id_token)
        if time.time() - decoded_claims["auth_time"] > 5 * 60:
            # Only allow sign-ins with tokens generated in the past 5 minutes
            return flask.abort(403, "Token deadline exceeded.")

        # Configure response to store ID token as a session cookie
        expires = datetime.datetime.now() + datetime.timedelta(days=5)
        response = make_response(redirect("/"))
        response.set_cookie(
            "session",
            id_token,
            expires=expires,
            httponly=True,
            secure=True,
            samesite="Strict",
        )

        return response
    except auth.InvalidIdTokenError as err:
        return abort(401, "Invalid ID token.")


@auth_bp.route("/login", methods=["GET"])
def login_get():
    if not current_app.config["SHOW_AUTH"]:
        return abort(404, "Login disabled")

    return render_template("auth/login.html")


@auth_bp.route("/logout", methods=["GET"])
def logout():
    response = make_response(redirect("/"))

    # Clear session token
    response.set_cookie("session", "", expires=0)

    return response
