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
from data import cloud_firestore as db
from resources import auth, base
from utils.logging import log


resource_fields = {
    "approvers": ["name", "email", "active"],
    "campaigns": [
        "name",
        "description",
        "cause",
        "managers",
        "goal",
        "imageUrl",
        "active",
    ],
    "causes": ["name", "description", "imageUrl", "active"],
    "donations": ["campaign", "donor", "amount"],
    "donors": ["name", "email", "mailing_address"],
}


# List all entities of the given resource_kind, if allowed,
# UNLESS the resource_kind is "donations". In that case, either
# list all donations (if the user is an approver) or only the
# authenticated user's donations
def list(resource_kind):
    log(f"Request to list {resource_kind}", severity="INFO")
    if resource_kind not in resource_fields:
        return "Not found", 404

    if not auth.allowed("GET", resource_kind):
        return "Forbidden", 403

    # Listing donations or donors are allowed for all,
    # but for non-approvers only a subset should return
    if resource_kind not in ["donations", "donors"]:
        # Already checked that this is allowed, so return all items
        results = db.list(resource_kind, resource_fields[resource_kind])

    elif auth.user_is_approver(g.verified_email):
        # Approvers get all donors or donations, no matter what
        results = db.list(resource_kind, resource_fields[resource_kind])

    else:
        # The verified user should see only their own records
        matching_donors = db.list_matching(
            "donors", resource_fields["donors"], "email", g.verified_email
        )

        if resource_kind == "donors":
            results = matching_donors
        else:
            # Find the donations matching the donors just found. Ideally,
            # one email address should match at most one donor, but more
            # are possible
            matching_donor_ids = set([donor["id"] for donor in matching_donors])

            # If we knew there was only one donor_id, then we could use
            # list_matching here instead of getting all then filtering.
            all_donations = db.list("donations", resource_fields["donations"])
            results = [
                item for item in all_donations if item["donor"] in matching_donor_ids
            ]

    return json.dumps(results), 200, {"Content-Type": "application/json"}


def list_subresource(resource_kind, id, subresource_kind):
    if resource_kind not in resource_fields or subresource_kind not in resource_fields:
        return "Not found", 404

    resource = db.fetch(resource_kind, id, resource_fields[resource_kind])
    if resource is None:
        return "Not found", 404

    # Only match subresources that match the resource
    match_field = resource_kind[:-1]  # Chop off the "s" to get the field name

    # e.g, fetch donations whose campaign/donor field matches the campaign's/donor's id
    matching_children = db.list_matching(
        subresource_kind,
        resource_fields[subresource_kind],
        match_field,
        id,  # Value must match parent id
    )

    email = g.verified_email

    if auth.user_is_approver(email):
        return json.dumps(matching_children), 200, {"Content-Type": "application/json"}

    if resource_kind == "campaigns" and auth.user_is_manager(email, id):
        return json.dumps(matching_children), 200, {"Content-Type": "application/json"}

    matching_donors = db.list_matching(
        "donors", resource_fields["donors"], "email", email
    )
    matching_donor_ids = set([donor["id"] for donor in matching_donors])
    results = [
        item for item in matching_children if item["donor"] in matching_donor_ids
    ]

    return json.dumps(results), 200, {"Content-Type": "application/json"}


def get(resource_kind, id):
    log(f"Request to get {resource_kind}", severity="INFO")
    if resource_kind not in resource_fields:
        return "Not found", 404, {}

    result = db.fetch(resource_kind, id, resource_fields[resource_kind])
    if result is None:
        return "Not found", 404, {}

    return (
        json.dumps(result),
        200,
        {"Content-Type": "application/json", "ETag": base.etag(result)},
    )


def insert(resource_kind, representation):
    if resource_kind not in resource_fields:
        return "Not found", 404

    if not auth.allowed("POST", resource_kind, representation):
        return "Forbidden", 403

    if resource_kind == "donors":  # Special case: enforce unique email
        if "email" not in representation:
            return "Bad request", 400

        matches = db.list_matching(
            "donors", resource_fields["donors"], "email", representation["email"]
        )
        if len(matches) == 0:
            resource = db.insert(
                resource_kind, representation, resource_fields[resource_kind]
            )
        else:  # Should be exactly one. If more, just take the first
            donor_id = matches[0]["id"]
            resource, status = db.update(
                "donors", donor_id, representation, resource_fields["donors"], None
            )
            if status != 200:
                return resource, status

        return (
            json.dumps(resource),
            201,
            {
                "Content-Type": "application/json",
                "ETag": base.etag(resource),
            },
        )

    if resource_kind == "donations":  # Special case: enforce referential integrity
        if (
            representation.get("campaign") is None
            or representation.get("donor") is None
        ):
            return "Bad request", 400

        _, status, _ = get("donors", representation["donor"])
        if status != 200:
            return "Not found", 404

        _, status, _ = get("campaigns", representation["campaign"])
        if status != 200:
            return "Not found", 404

        resource = db.insert(
            resource_kind, representation, resource_fields[resource_kind]
        )

    else:
        resource = db.insert(
            resource_kind, representation, resource_fields[resource_kind]
        )

    return (
        json.dumps(resource),
        201,
        {
            "Content-Type": "application/json",
            "ETag": base.etag(resource),
        },
    )


def patch(resource_kind, id, representation):
    if resource_kind not in resource_fields:
        return "Not found", 404

    match_etag = request.headers.get("If-Match", None)
    resource, status = db.update(
        resource_kind, id, representation, resource_fields[resource_kind], match_etag
    )

    if resource is None:
        return "", status

    return (
        json.dumps(resource),
        201,
        {
            "Content-Type": "application/json",
            "Location": resource["selfLink"],
            "ETag": base.etag(resource),
        },
    )


def delete(resource_kind, id):
    if resource_kind not in resource_fields:
        return "Not found", 404

    match_etag = request.headers.get("If-Match", None)
    status = db.delete(resource_kind, id, resource_fields[resource_kind], match_etag)

    return "", status
