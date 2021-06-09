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

from flask import Flask, redirect, request, render_template

app = Flask(__name__)

# TODO(anassri, engelke): use API call instead of this
# (This is based on the API design doc for now.)

SAMPLE_CAMPAIGNS = [
    {
        "id": "aaaa-bbbb-cccc-dddd",
        "name": "cash for camels",
        "goal": 2500,
        "managers": ["Chris the camel", "Carissa the camel"],
        "updated": datetime.date(2021, 2, 1),
    },
    {
        "id": "eeee-ffff-gggg-hhhh",
        "name": "water for fish",
        "goal": 2500,
        "managers": [
            "Fred the fish",
        ],
        "updated": datetime.date(2021, 5, 10),
    },
]


@app.route("/")
def webapp_list_campaigns():
    return render_template("home.html", campaigns=SAMPLE_CAMPAIGNS)


@app.route("/createCampaign", methods=["GET"])
def webapp_create_campaign_get():
    return render_template("create-campaign.html")


@app.route("/createCampaign", methods=["POST"])
def webapp_create_campaign_post():
    # TODO: do something with the collected data
    print("Name: ", request.form["name"])
    print("Goal: ", request.form["goal"])
    print("Managers: ", request.form["managers"])

    return redirect("/")


@app.route("/viewCampaign")
def webapp_view_campaign():
    campaign_id = request.args["campaign_id"]
    campaign_instance = [
        campaign for campaign in SAMPLE_CAMPAIGNS if campaign["id"] == campaign_id
    ][0]
    return render_template("view-campaign.html", campaign=campaign_instance)


if __name__ == "__main__":
    PORT = int(os.getenv("PORT")) if os.getenv("PORT") else 8080

    # This is used when running locally. Gunicorn is used to run the
    # application on Cloud Run. See entrypoint in Dockerfile.
    app.run(host="127.0.0.1", port=PORT, debug=True)