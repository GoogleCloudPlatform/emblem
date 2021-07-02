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
    Manages API operations for the donations resource type, implementing
    standard methods:

        list    Return all donations
        get     Return a single donation
        insert  Create a new donation
        patch   Update a donation
        delete  Remove a donation

    Includes these standard properties:

        kind        "donations"
        id          unique system generated identifier
        timeCreated timestamp; when this was created
        updated     timestamp; when this was last updated
        selfLink    the path of the URI for this resource

    Includes donation specific properties:

        campaign    ID of the campaign this donation is for
        donor       ID of the donor making this donation
        amount      the amount in USD of the donation

    All properties are strings, unless otherwise noted in the description.

    Since JSON does not have a date or datetime format, all timestamps are
    strings in RFC 3339 format for UTC, as in YYYY-MM-DDTHH:MM:SS.ffffffZ.
"""


import json
from google.cloud import firestore

from main import request
from resources import base


user_fields = ["campaign", "donor", "amount"]


def list():
    donations_collection = base.db.collection("donations")
    representations_list = []
    for donation in donations_collection.stream():
        resource = donation.to_dict()
        resource["id"] = donation.id
        resource["timeCreated"] = donation.create_time.rfc3339()
        resource["updated"] = donation.update_time.rfc3339()
        representations_list.append(
            base.canonical_resource(resource, "donations", user_fields)
        )

    return json.dumps(representations_list), 200, {"Content-Type": "application/json"}


def get(id):
    donation_reference = base.db.document("donations/{}".format(id))
    donation_snapshot = donation_reference.get()
    if not donation_snapshot.exists:
        return "Not found", 404

    resource = donation_snapshot.to_dict()
    resource["id"] = donation_snapshot.id
    resource["timeCreated"] = donation_snapshot.create_time.rfc3339()
    resource["updated"] = donation_snapshot.update_time.rfc3339()

    resource = base.canonical_resource(resource, "donations", user_fields)

    return json.dumps(resource), 200, {
        "Content-Type": "application/json",
        "ETag": base.etag(resource)
    }


def insert(representation):
    resource = {"kind": "donations"}
    for field in user_fields:
        resource[field] = representation.get(field, None)

    doc_ref = base.db.collection("donations").document()
    doc_ref.set(resource)

    resource = base.canonical_resource(
        base.snapshot_to_resource(doc_ref.get()),
        "donations",
        user_fields,
    )

    return json.dumps(resource), 201, {
        "Content-Type": "application/json",
        "Location": resource["selfLink"],
        "ETag": base.etag(resource)
        }


def patch(id, representation):
    transaction = base.db.transaction()
    donation_reference = base.db.document("donations/{}".format(id))

    @firestore.transactional
    def update_in_transaction(transaction, donation_reference, representation):
        donation_snapshot = donation_reference.get(transaction=transaction)
        if not donation_snapshot.exists:
            return "Not found", 404

        resource = base.canonical_resource(
            base.snapshot_to_resource(donation_snapshot), "donations", user_fields
        )

        if 'If-Match' in request.headers:   # Only apply if resource has not changed
            if request.headers.get('If-Match') != base.etag(resource):
                return "Conflict", 409

        transaction.update(donation_reference, representation)
        return "Updated", 204

    return update_in_transaction(transaction, donation_reference, representation)


def delete(id):
    donation_reference = base.db.document("donations/{}".format(id))
    donation_snapshot = donation_reference.get()
    if not donation_snapshot.exists:
        return "Not found", 404

    resource = base.canonical_resource(
        base.snapshot_to_resource(donation_snapshot), "donations", user_fields
    )

    if 'If-Match' in request.headers:   # Only apply if resource has not changed
        if request.headers.get('If-Match') != base.etag(resource):
            return "Conflict", 409

    donation_reference.delete()
    return "Deleted", 204
