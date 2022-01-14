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

import json
from flask import jsonify, after_this_request, Blueprint, g, redirect, request, render_template
from middleware.logging import log
from views.helpers.donors import get_donor_name
from views.helpers.time import convert_utc
from functools import reduce
import re

routes_bp = Blueprint("routes", __name__, template_folder="templates")

def convert_to_json(o):
    #TODO: throw error if param given is undefined
    if o is not None:
        if isinstance(o, list):
            return json.dumps([item.__dict__['_data_store'] for item in o], indent=4, sort_keys=True, default=str)
        else:
            return json.dumps(o.__dict__['_data_store'], indent=4, sort_keys=True, default=str)
# ----------------------------------------

@routes_bp.route("/api/v1/campaigns")
def get_campaigns():
    @after_this_request
    # Enable Access-Control-Allow-Origin
    def add_header(response):
        response.headers.add('Access-Control-Allow-Origin', '*')
        return response

    try:
        campaigns = g.api.campaigns_get()
    except Exception as e:
        log(f"Exception when listing campaigns: {e}", severity="ERROR")
        campaigns = []

    return convert_to_json(campaigns)

@routes_bp.route("/api/v1/campaign", methods=["GET"])
def new_campaign():
    # Enable Access-Control-Allow-Origin
    @after_this_request
    def add_header(response):
        return response.headers.add('Access-Control-Allow-Origin', '*')

    try:
        causes = g.api.causes_get()
    except Exception as e:
        log(f"Exception when listing causes: {e}", severity="ERROR")
        causes = []

    return convert_to_json(causes)

@routes_bp.route("/api/v1/campaign", methods=["POST"])
def save_campaign():
    # Enable Access-Control-Allow-Origin
    @after_this_request
    def add_header(response):
        return response.headers.add('Access-Control-Allow-Origin', '*')

    newCampaign = {
        "name": request.form["name"],
        "cause": request.form["cause"],
        "imageUrl": request.form["imageUrl"],
        "description": request.form["description"],
        "goal": float(request.form["goal"]),
        "managers": re.split(r"[ ,]+", request.form["managers"]),
        "active": True,
    }

    try:
        g.api.campaigns_post(newCampaign)
    except Exception as e:
        log(f"Exception when creating a campaign: {e}", severity="ERROR")
        return json.dumps({ 'status': 403 })

    return convert_to_json(newCampaign)

@routes_bp.route("/api/v1/get_campaign")
def webapp_view_campaign():
    campaign_id = request.args.get("campaign_id")
  
    if campaign_id is None:
        log(f"/viewCampaign is missing campaign_id", severity="ERROR")
        return json.dumps({ 'status': 500 })
    try:
        campaign_instance = g.api.campaigns_id_get(campaign_id)
        campaign_instance["formattedDateCreated"] = convert_utc(
            campaign_instance.time_created
        )
        campaign_instance["formattedDateUpdated"] = convert_utc(
            campaign_instance.updated
        )
    except Exception as e:
        log(f"Exception when fetching campaigns {campaign_id}: {e}", severity="ERROR")
        return json.dumps({ 'status': 403 })

    campaign_instance["donations"] = []
    campaign_instance["raised"] = 0
    campaign_instance["percent_complete"] = 0

    try:
        donations = g.api.campaigns_id_donations_get(campaign_instance["id"])
        if len(donations) > 0:
            campaign_instance["donations"] = list(map(get_donor_name, donations))
            raised = reduce(
                lambda t, d: t + int(d["amount"] if d is not None else 0), donations, 0
            )
            campaign_instance["raised"] = raised
            campaign_instance["percent_complete"] = (
                (raised / float(campaign_instance.goal)) * 100
                if raised is not None
                else 0
            )
    except Exception as e:
        log(f"Exception when listing campaign donations: {e}", severity="ERROR")
        return json.dumps({ 'status': 403 })
    
    return convert_to_json(campaign_instance)