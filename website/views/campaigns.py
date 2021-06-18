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

# TODO(ace-n): replace this with an API call
from sample_data import SAMPLE_DONATIONS

from flask import Blueprint, redirect, request, render_template

import requests

campaigns_bp = Blueprint("campaigns", __name__, template_folder="templates")

API_URL = 'https://api-pwrmtjf4hq-uc.a.run.app'

@campaigns_bp.route("/")
def list_campaigns():
    campaigns = requests.get(API_URL + '/campaigns').json()
    return render_template("home.html", campaigns=campaigns)


@campaigns_bp.route("/createCampaign", methods=["GET"])
def new_campaign():
    return render_template("create-campaign.html")


@campaigns_bp.route("/createCampaign", methods=["POST"])
def save_campaign():
    # TODO: do something with the collected data
    print("Name: ", request.form["name"])
    print("Goal: ", request.form["goal"])
    print("Managers: ", request.form["managers"])

    return redirect("/")


@campaigns_bp.route("/viewCampaign")
def webapp_view_campaign():
    campaigns = requests.get(API_URL + '/campaigns').json()
    campaign_instance = campaigns[0]
    return render_template("view-campaign.html", campaign=campaign_instance)
