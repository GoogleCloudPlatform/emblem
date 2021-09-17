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


import os
from flask import Blueprint, g, redirect, request, render_template


donations_bp = Blueprint("donations", __name__, template_folder="templates")


@donations_bp.route("/donate", methods=["GET"])
def new_donation():
    campaigns = g.api.campaigns_get()
    campaign_instance = campaigns[0]
    return render_template("donations/new-donation.html", campaign=campaign_instance)


@donations_bp.route("/donate", methods=["POST"])
def record_donation():
    campaign_id = request.form.get("campaignId", "Missing Campaign ID")
    donor_id = request.form.get("donor", "Missing Donor ID")
    amount = float(request.form.get("amount"))

    new_donation = {"campaign": campaign_id, "donor": donor_id, "amount": amount}

    donation = g.api.donations_post(new_donation)
    return redirect("/viewDonation?donation_id=" + donation.id)


@donations_bp.route("/viewDonation", methods=["GET"])
def webapp_view_donation():
    donation_id = request.args.get("donation_id")
    donation_instance = g.api.donations_id_get(donation_id)

    campaign_instance = g.api.campaigns_id_get(donation_instance.campaign)

    return render_template(
        "donations/view-donation.html",
        donation=donation_instance,
        campaign=campaign_instance,
    )
