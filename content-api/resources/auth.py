# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


import json

from main import g, request
from resources import methods
from data import cloud_firestore as db


def user_is_approver(email):
    if email is None:
        return False
    matching_approvers = db.list_matching(
        "approvers", methods.resource_fields["approvers"], "email",  email
    )
    return len(matching_approvers) > 0


def user_is_manager(email, campaign_id):
    if email is None:
        return False
    campaign = db.fetch("campaigns", campaign_id, methods.resource_fields["campaigns"])
    if campaign is None or campaign.fetch("managers") is None:
        return False
    return email in campaign["managers"]


def allowed(operation, resource_kind, representation=None):
    email = g.get("verified_email", None)

    # Check for everything requiring auth and handle

    if user_is_approver(email):
        return True
        
    if resource_kind in ["campaigns", "causes"]:
        if operation == "POST":
            return user_is_approver(email)
        if operation in ["PATCH","DELETE"]:
            path_parts = request.path.split("/")
            id = path_parts[1]
            return user_is_approver(email) or user_is_manager(email, id)
        return True

    if resource_kind == "donors":
        if operation == "POST":
            donor_email = representation.get("email")
            return donor_email == email
        if operation in ["PATCH", "DELETE"]:
            return user_is_approver(email)
        return True

    if resource_kind == "donations":
        campaign_id = representation.get("campaign")
        donor_id = representation.get("donor")

        if donor_email is None or campaign_id is None:
            return False
        if operation == "GET":
            return user_is_manager(email, campaign_id)
        if operation == "POST":
            donor = db.fetch("donors", donor_id, methods.resource_fields["donors"])
            if donor is None or donor.get("email") is None:
                return False
            return donor["email"] == email

    # No other case requires authorization
    return True

