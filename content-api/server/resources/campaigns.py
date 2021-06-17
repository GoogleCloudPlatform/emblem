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


"""
    Manages API operations for the campaigns resource type, implementing
    standard methods:

        list    Return all campaigns
        get     Return a single campaign
        insert  Create a new campaign
        patch   Update a campaign
        delete  Remove a campaign

    Includes these standard properties:

        kind        "campaigns"
        id          unique system generated identifier
        timeCreated timestamp; when this was created
        updated     timestamp; when this was last updated
        selfLink    the path of the URI for this resource
        etag        a value unique to the current state of the campaign resource

    Includes campaign specific properties:

        name        the display name of the campaign
        description string describing the purpose of the campaign
        cause       the id of the cause this campaign is for
        managers    array of strings containing email addresses of contact persons
        goal        the amount in USD this campaign is trying to raise
        imageUrl    string containing URL of an image to display
        active      boolean; whether this person can currently approve

    All properties are strings, unless otherwise noted in the description.

    Since JSON does not have a date or datetime format, all timestamps are
    strings in RFC 3339 format for UTC, as in YYYY-MM-DDTHH:MM:SS.ffffffZ.
"""


import json
from google.cloud import firestore

from resources import base


user_fields = ["name", "description", "cause", "managers", "goal", "imageUrl", "active"]


def list():
    campaigns_collection = base.db.collection("campaigns")
    representations_list = []
    for campaign in campaigns_collection.stream():
        resource = campaign.to_dict()
        resource["id"] = campaign.id
        resource["timeCreated"] = campaign.create_time.rfc3339()
        resource["updated"] = campaign.update_time.rfc3339()
        representations_list.append(
            base.canonical_resource(resource, "campaigns", user_fields)
        )

    return json.dumps(representations_list), 200, {"Content-Type": "application/json"}


def get(id):
    campaign_reference = base.db.document("campaigns/{}".format(id))
    campaign_snapshot = campaign_reference.get()
    if not campaign_snapshot.exists:
        return "Not found", 404

    resource = campaign_snapshot.to_dict()
    resource["id"] = campaign_snapshot.id
    resource["timeCreated"] = campaign_snapshot.create_time.rfc3339()
    resource["updated"] = campaign_snapshot.update_time.rfc3339()

    resource = base.canonical_resource(resource, "campaigns", user_fields)

    return json.dumps(resource), 200, {"Content-Type": "application/json"}


def insert(representation):
    resource = {"kind": "campaigns"}
    for field in user_fields:
        resource[field] = representation.get(field, None)

    doc_ref = base.db.collection("campaigns").document()
    doc_ref.set(resource)

    resource = base.canonical_resource(
        base.snapshot_to_resource(doc_ref.get()),
        "campaigns",
        user_fields,
    )

    return json.dumps(resource), 201, {
        "Content-Type": "application/json",
        "Location": resource["selfLink"]
        }


def patch(id, representation):
    transaction = base.db.transaction()
    campaign_reference = base.db.document("campaigns/{}".format(id))

    @firestore.transactional
    def update_in_transaction(transaction, campaign_reference, representation):
        campaign_snapshot = campaign_reference.get(transaction=transaction)
        if not campaign_snapshot.exists:
            return "Not found", 404

        resource = base.canonical_resource(
            base.snapshot_to_resource(campaign_snapshot), "campaigns", user_fields
        )

        if "etag" in representation:
            if representation["etag"] != resource["etag"]:
                return "Conflict", 409

        transaction.update(campaign_reference, representation)
        return "OK", 200

    return update_in_transaction(transaction, campaign_reference, representation)


def delete(id):
    campaign_reference = base.db.document("campaigns/{}".format(id))
    campaign_snapshot = campaign_reference.get()
    if not campaign_snapshot.exists:
        return "Not found", 404

    campaign_reference.delete()
    return "", 204
