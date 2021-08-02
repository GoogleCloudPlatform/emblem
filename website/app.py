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

from flask import Flask, redirect, request, render_template

from views.campaigns import campaigns_bp
from views.donations import donations_bp
from views.errors import errors_bp
from views.auth import auth_bp

app = Flask(__name__)
app.register_blueprint(errors_bp)
app.register_blueprint(donations_bp)
app.register_blueprint(campaigns_bp)
app.register_blueprint(auth_bp)

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
    app.run(host="127.0.0.1", port=PORT)
