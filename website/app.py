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
import secrets

from flask import Flask, g, redirect, request, render_template

import emblem_client

from views.campaigns import campaigns_bp
from views.donations import donations_bp
from views.errors import errors_bp
from views.auth import auth_bp
from views.robots_txt import robots_txt_bp

app = Flask(__name__)
app.register_blueprint(errors_bp)
app.register_blueprint(donations_bp)
app.register_blueprint(campaigns_bp)
app.register_blueprint(auth_bp)
app.register_blueprint(robots_txt_bp)

if os.path.exists("config.py"):
    app.config.from_object("config")
else:
    print("WARNING: config.py file not found! Some features may be broken.")


# Determine whether (Firebase) auth config is valid
api_key = app.config.get("FIREBASE_API_KEY", "")
domain = app.config.get("FIREBASE_AUTH_DOMAIN")
valid_auth_config = (
    "AIza" in api_key and domain and domain != "YOUR_APP.firebaseapp.com"
)

app.config["SHOW_AUTH"] = valid_auth_config or (not os.getenv("HIDE_AUTH_WARNINGS"))


# TODO(anassri, engelke): move these to a "middleware" folder
@app.before_request
def check_user_authentication():
    id_token = None

    auth = request.headers.get("Authorization", None)
    if auth is not None:
        id_token = auth[7:]  # Remove "Bearer: " prefix

    g.api = emblem_client.EmblemClient(
        os.environ.get("API_URL", None), access_token=id_token
    )


@app.before_request
def set_csp_nonce():
    g.csp_nonce = secrets.token_urlsafe(32)


@app.after_request
def set_csp_policy(response):
    image_origins = " ".join([
        "'self'",
        'images.pexels.com',
        'github.githubassets.com'
    ])

    font_origins = " ".join([
        'fonts.gstatic.com',
        'fonts.googleapis.com'
    ])

    policy = "; ".join([
        f"img-src {image_origins}",
        f"font-src {font_origins}",
        f"script-src 'nonce-{g.csp_nonce}'",

        # Static fields requested by Lighthouse CI
        "object-src 'none'",
        "base-uri 'self'"
    ])
    
    response.headers["Content-Security-Policy"] = policy
    return response

# TODO(anassri, engelke): use API call instead of this
# (This is based on the API design doc for now.)

SAMPLE_CAMPAIGNS = [
    {
        "id": "aaaa-bbbb-cccc-dddd",
        "name": "cash for camels",
        "image_url": "https://images.pexels.com/photos/2080195/pexels-photo-2080195.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
        "goal": 2500,
        "managers": ["Chris the camel", "Carissa the camel"],
        "description": "The camels need money.",
        "updated": datetime.date(2021, 2, 1),
        "donations": ["cccc-oooo-oooo-llll"],
    },
    {
        "id": "eeee-ffff-gggg-hhhh",
        "name": "water for fish",
        "image_url": "https://images.pexels.com/photos/2156311/pexels-photo-2156311.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
        "goal": 2500,
        "managers": [
            "Fred the fish",
        ],
        "description": "Help us keep all the fish hydrated!",
        "updated": datetime.date(2021, 5, 10),
        "donations": [],
    },
]

SAMPLE_DONATIONS = [
    {
        "id": "cccc-oooo-oooo-llll",
        "campaign": "aaaa-bbbb-cccc-dddd",
        "donor": "aaaa-dddd-aaaa-mmmm",
        "amount": 100,
        "timeCreated": datetime.date(2021, 5, 20),
    }
]


if __name__ == "__main__":
    PORT = int(os.getenv("PORT")) if os.getenv("PORT") else 8080

    # This is used when running locally. Gunicorn is used to run the
    # application on Cloud Run; see "entrypoint" parameter in the Dockerfile.
    app.run(host="127.0.0.1", port=PORT, debug=True)
