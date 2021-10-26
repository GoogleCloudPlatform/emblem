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

from datetime import datetime
from os import curdir
from flask import g, current_app, session
import requests

import emblem_client


def init(app):
    @app.before_request
    def check_user_authentication():
        print(f"DEBUG - getting session info: {session}")
        id_token = session.get("id_token")
        expiration = session.get("expiration")
        print(f"DEBUG - id_token is {id_token} and expiration is {expiration}")

        if (
            expiration is not None
            and expiration - datetime.timestamp(datetime.now()) < 30   # seconds
        ):
            id_token, expiration = get_refreshed_token(session.get("refresh_token"))
            session["id_token"] = id_token
            session["expiration"] = expiration

        g.api = emblem_client.EmblemClient(
            app.config.get("API_URL", None), access_token=id_token
        )


def get_refreshed_token(refresh_token):
    print(f"DEBUG - refresh token is {refresh_token}")
    if refresh_token is not None:
        print("DEBUG - asking for a refreshed ID token")
        response = requests.post(
            "https://oauth2.googleapis.com/token",
            {
                "client_id": current_app.config["CLIENT_ID"],
                "client_secret": current_app.config["CLIENT_SECRET"],
                "refresh_token": refresh_token,
                "grant_type": "refresh_token",
            },
        )

        print(f"DEBUG - the response to that is {response.text}")
        try:
            updates = response.json()
        except Exception as e:
            print(f"ERROR: exception {e} when parsing refresh response.")
            print(f"response text is {response.text}")
            return None, None

        id_token = updates.get("id_token")
        expiration = datetime.timestamp(datetime.now()) + updates.get("expires_in")
        return id_token, expiration

    else:
        print(f"WARNING: request for refreshed token returned None")
        return None, None
