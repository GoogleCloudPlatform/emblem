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
    Manages API operations for the Donors resource type, implementing
    standard methods:

        list    Return all donors
        get     Return a single donor
        insert  Create a new donor
        patch   Update a donor
        delete  Remove a donor

    Includes these standard properties:

        kind        "donors"
        id          unique system generated identifier
        timeCreated timestamp; when this was created
        updated     timestamp; when this was last updated
        selfLink    the path of the URI for this resource

    Includes donor specific properties:

        name            the display name of the donor
        email           the donor's email address
        mailing_address the physical address of the donor

    All properties are strings, unless otherwise noted in the description.

    Since JSON does not have a date or datetime format, all timestamps are
    strings in RFC 3339 format for UTC, as in YYYY-MM-DDTHH:MM:SS.ffffffZ.
"""


import json
from google.cloud import firestore

from main import request
from resources import base


user_fields = ["name", "email", "mailing_address"]


def list():
    donors_collection = base.db.collection("donors")
    representations_list = []
    for donor in donors_collection.stream():
        resource = donor.to_dict()
        resource["id"] = donor.id
        resource["timeCreated"] = donor.create_time.rfc3339()
        resource["updated"] = donor.update_time.rfc3339()
        representations_list.append(
            base.canonical_resource(resource, "donors", user_fields)
        )

    return json.dumps(representations_list), 200, {"Content-Type": "application/json"}


def get(id):
    donor_reference = base.db.document("donors/{}".format(id))
    donor_snapshot = donor_reference.get()
    if not donor_snapshot.exists:
        return "Not found", 404

    resource = donor_snapshot.to_dict()
    resource["id"] = donor_snapshot.id
    resource["timeCreated"] = donor_snapshot.create_time.rfc3339()
    resource["updated"] = donor_snapshot.update_time.rfc3339()

    resource = base.canonical_resource(resource, "donors", user_fields)

    return json.dumps(resource), 200, {
        "Content-Type": "application/json",
        "ETag": base.etag(resource)
    }


def insert(representation):
    resource = {"kind": "donors"}
    for field in user_fields:
        resource[field] = representation.get(field, None)

    doc_ref = base.db.collection("donors").document()
    doc_ref.set(resource)

    resource = base.canonical_resource(
        base.snapshot_to_resource(doc_ref.get()),
        "donors",
        user_fields,
    )

    return json.dumps(resource), 201, {
        "Content-Type": "application/json",
        "Location": resource["selfLink"],
        "ETag": base.etag(resource)
        }


def patch(id, representation):
    transaction = base.db.transaction()
    donor_reference = base.db.document("donors/{}".format(id))

    @firestore.transactional
    def update_in_transaction(transaction, donor_reference, representation):
        donor_snapshot = donor_reference.get(transaction=transaction)
        if not donor_snapshot.exists:
            return "Not found", 404

        resource = base.canonical_resource(
            base.snapshot_to_resource(donor_snapshot), "donors", user_fields
        )

        if 'If-Match' in request.headers:   # Only apply if resource has not changed
            if request.headers.get('If-Match') != base.etag(resource):
                return "Conflict", 409

        transaction.update(donor_reference, representation)
        return "Updated", 204

    return update_in_transaction(transaction, donor_reference, representation)


def delete(id):
    donor_reference = base.db.document("donors/{}".format(id))
    donor_snapshot = donor_reference.get()
    if not donor_snapshot.exists:
        return "Not found", 404

    resource = base.canonical_resource(
        base.snapshot_to_resource(donor_snapshot), "donors", user_fields
    )

    if 'If-Match' in request.headers:   # Only apply if resource has not changed
        if request.headers.get('If-Match') != base.etag(resource):
            return "Conflict", 409

    donor_reference.delete()
    return "Deleted", 204
