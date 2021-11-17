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

from flask import Blueprint, g, redirect, request, render_template

from middleware.logging import log

import re


campaigns_bp = Blueprint("campaigns", __name__, template_folder="templates")


@campaigns_bp.route("/")
def list_campaigns():
    try:
        campaigns = g.api.campaigns_get()
    except Exception as e:
        log(f"Exception when listing campaigns: {e}", severity="ERROR")
        campaigns = []

    return render_template("home.html", campaigns=campaigns)


@campaigns_bp.route("/createCampaign", methods=["GET"])
def new_campaign():
    try:
        causes = g.api.causes_get()
    except Exception as e:
        log(f"Exception when listing causes: {e}", severity="ERROR")
        causes = []

    return render_template("create-campaign.html", causes=causes)


@campaigns_bp.route("/createCampaign", methods=["POST"])
def save_campaign():
    try:
        g.api.campaigns_post(
            {
                "name": request.form["name"],
                "cause": request.form["cause"],
                "imageUrl": request.form["imageUrl"],
                "description": request.form["description"],
                "goal": float(request.form["goal"]),
                "managers": re.split(r"[ ,]+", request.form["managers"]),
                "active": True,
            }
        )
    except Exception as e:
        log(f"Exception when creating a campaign: {e}", severity="ERROR")
        return render_template("errors/403.html"), 403

    return redirect("/")


@campaigns_bp.route("/viewCampaign")
def webapp_view_campaign():
    campaign_id = request.args.get("campaign_id")
    if campaign_id is None:
        log(f"/viewCampaign is missing campaign_id", severity="ERROR")
        return render_template("errors/500.html"), 500

    try:
        campaign_instance = g.api.campaigns_id_get(campaign_id)
    except Exception as e:
        log(f"Exception when fetching campaigns {campaign_id}: {e}", severity="ERROR")
        return render_template("errors/403.html"), 403

    campaign_instance["donations"] = []

    try:
        campaign_instance["donations"] = g.api.campaigns_id_donations_get(
            campaign_instance["id"]
        )
    except Exception as e:
        log(f"Exception when listing campaign donations: {e}", severity="ERROR")
        return render_template("errors/403.html"), 403

    return render_template("view-campaign.html", campaign=campaign_instance)
