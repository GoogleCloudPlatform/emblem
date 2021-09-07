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

from flask import Blueprint, redirect, request, render_template

import os
import requests

import emblem_api


campaigns_bp = Blueprint("campaigns", __name__, template_folder="templates")

API_URL = "https://api-pwrmtjf4hq-uc.a.run.app"


@campaigns_bp.route("/")
def list_campaigns():
    api = emblem_api.EmblemApi(os.environ.get("API_URL", None))
    campaigns = api.campaigns_get()
    return render_template("home.html", campaigns=campaigns)


@campaigns_bp.route("/createCampaign", methods=["GET"])
def new_campaign():
    return render_template("create-campaign.html")


@campaigns_bp.route("/createCampaign", methods=["POST"])
def save_campaign():
    access_key = None
    auth_header = request.header.get("Authorization", None)
    if auth_header is not None:
        access_key = auth_header[:7]
    api = emblem_api.EmblemApi(os.environ.get("API_URL", None), access_key=access_key)
    # TODO: do something with the collected data
    api.campaigns_post({
        "name": request.form["name"],
        "goal": request.form["goal"],
        "managers": request.form["managers"]
    })

    return redirect("/")


@campaigns_bp.route("/viewCampaign")
def webapp_view_campaign():
    access_key = None
    auth_header = request.header.get("Authorization", None)
    if auth_header is not None:
        access_key = auth_header[:7]
    api = emblem_api.EmblemApi(os.environ.get("API_URL", None), access_key=access_key)

    campaigns = api.campaigns_get()
    campaign_instance = campaigns[0]

    # Add dummy data for donations
    campaign_instance["donations"] = []
    campaign_instance["donations"] = api.campaigns_id_donations_get(campaign_instance["id"])

    return render_template("view-campaign.html", campaign=campaign_instance)
