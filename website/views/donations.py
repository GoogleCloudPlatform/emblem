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


# TODO(ace-n): replace this with API call
from sample_data import SAMPLE_DONATIONS

from flask import Blueprint, redirect, request, render_template

import requests

donations_bp = Blueprint("donations", __name__, template_folder="templates")

API_URL = "https://api-pwrmtjf4hq-uc.a.run.app"

@donations_bp.route("/donate", methods=["GET"])
def new_donation():
    campaigns = requests.get(API_URL + "/campaigns").json()
    campaign_instance = campaigns[0]
    return render_template("donations/new-donation.html", campaign=campaign_instance)


@donations_bp.route("/donate", methods=["POST"])
def record_donation():
    # TODO: do something with the collected data
    campaigns = requests.get(API_URL + "/campaigns").json()
    campaign_instance = campaigns[0]

    donation_id = campaign_instance["donations"][0]

    print("Amount: ", request.form["amount"])

    return redirect("/viewDonation?donation_id=" + donation_id)


@donations_bp.route("/viewDonation", methods=["GET"])
def webapp_view_donation():
    donation_id = "cccc-oooo-oooo-llll"  # TODO: fetch value from API
    donation_instance = [
        donation for donation in SAMPLE_DONATIONS if donation["id"] == donation_id
    ][0]

    campaign_id = donation_instance["campaign"]
    campaign_instance = [
        campaign for campaign in SAMPLE_CAMPAIGNS if campaign["id"] == campaign_id
    ][0]

    return render_template(
        "donations/view-donation.html",
        donation=donation_instance,
        campaign=campaign_instance,
    )
