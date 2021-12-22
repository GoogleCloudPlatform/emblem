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

from middleware import session
from middleware.logging import log


donations_bp = Blueprint("donations", __name__, template_folder="templates")


@donations_bp.route("/donate", methods=["GET"])
def new_donation():
    if g.session_data is None:
        log(f"Asking to make a donation when not logged in", severity="INFO")

    campaign_id = request.args.get("campaign_id")
    if campaign_id is None:
        log(f"/donate is missing campaign_id", severity="ERROR")
        return render_template("errors/500.html"), 500

    try:
        campaign = g.api.campaigns_id_get(campaign_id)
    except Exception as e:
        log(f"Exception when fetching campaign {campaign_id}: {e}", severity="ERROR")
        return render_template("errors/500.html"), 500

    return render_template("donations/new-donation.html", campaign=campaign)


@donations_bp.route("/donate", methods=["POST"])
def record_donation():
    session_data = g.session_data
    
    if session_data is None:
        log(f"Exception when donating. User has no session.", severity="INFO")
        return render_template("errors/403.html"), 403
    
    # Retrieving name and address from form
    donor_name = request.form.get("name")
    donor_address = {
      "street": request.form.get('street'),
      "city": request.form.get('city'),
      "state": request.form.get('state'),
      "zipcode": request.form.get('zipcode')
    }

    try:
        donor = g.api.donors_post({
            "name": donor_name if donor_name else "Unknown",
            "email": session_data["email"],
            "mailing_address": str(donor_address)
       })
    except Exception as e:
        log(f"Exception when creating a donor: {e}", severity="ERROR")
        return render_template("errors/403.html"), 403

    campaign_id = request.form.get("campaignId")
    try:
        campaign = g.api.campaigns_id_get(campaign_id)
    except Exception as e:
        log(
            f"Exception: donation for a non-existent campaign: {campaign_id}: {e}",
            severity="ERROR",
        )
        return render_template("errors/500.html"), 500

    donor_id = donor["id"]
    amount = float(request.form.get("amount"))
    new_donation = {
      "campaign": campaign_id,
      "donor": donor_id,
      "amount": amount,
    }

    try:
        donation = g.api.donations_post(new_donation)
    except Exception as e:
        log(f"Exception when creating a donation: {e}", severity="ERROR")
        return render_template("errors/403.html"), 403

    return redirect("/viewDonation?donation_id=" + donation.id)


@donations_bp.route("/viewDonation", methods=["GET"])
def webapp_view_donation():
    donation_id = request.args.get("donation_id")
    try:
        donation_instance = g.api.donations_id_get(donation_id)
    except Exception as e:
        log(f"Exception when getting a donation: {e}", severity="ERROR")
        return render_template("errors/403.html"), 403

    try:
        campaign_instance = g.api.campaigns_id_get(donation_instance.campaign)
    except Exception as e:
        log(f"Exception when getting a campaign for a donations: {e}", severity="ERROR")
        return render_template("errors/403.html"), 403

    return render_template(
        "donations/view-donation.html",
        donation=donation_instance,
        campaign=campaign_instance,
    )
