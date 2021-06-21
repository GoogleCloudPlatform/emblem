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
    Manages API operations for the approvers resource type, implementing
    standard methods:

        list    Return all approvers
        get     Return a single approver
        insert  Create a new approver
        patch   Update an approver
        delete  Remove an approver

    Includes these standard properties:

        kind        "approvers"
        id          unique system generated identifier
        timeCreated timestamp; when this was created
        updated     timestamp; when this was last updated
        selfLink    the path of the URI for this resource

    Includes Approver specific properties:

        name        the person's actual name
        email       how to reach this person
        active      boolean; whether this person can currently approve

    All properties are strings, unless otherwise noted in the description.

    Since JSON does not have a date or datetime format, all timestamps are
    strings in RFC 3339 format for UTC, as in YYYY-MM-DDTHH:MM:SS.ffffffZ.
"""


import json
from google.cloud import firestore

from main import request
from resources import base


user_fields = ["name", "email", "active"]


def list():
    approvers_collection = base.db.collection("approvers")
    representations_list = []
    for approver in approvers_collection.stream():
        resource = approver.to_dict()
        resource["id"] = approver.id
        resource["timeCreated"] = approver.create_time.rfc3339()
        resource["updated"] = approver.update_time.rfc3339()
        representations_list.append(
            base.canonical_resource(resource, "approvers", user_fields)
        )

    return json.dumps(representations_list), 200, {"Content-Type": "application/json"}


def get(id):
    approver_reference = base.db.document("approvers/{}".format(id))
    approver_snapshot = approver_reference.get()
    if not approver_snapshot.exists:
        return "Not found", 404

    resource = approver_snapshot.to_dict()
    resource["id"] = approver_snapshot.id
    resource["timeCreated"] = approver_snapshot.create_time.rfc3339()
    resource["updated"] = approver_snapshot.update_time.rfc3339()

    resource = base.canonical_resource(resource, "approvers", user_fields)

    return json.dumps(resource), 200, {
        "Content-Type": "application/json",
        "ETag": base.etag(resource)
    }


def insert(representation):
    resource = {"kind": "approvers"}
    for field in user_fields:
        resource[field] = representation.get(field, None)

    doc_ref = base.db.collection("approvers").document()
    doc_ref.set(resource)

    resource = base.canonical_resource(
        base.snapshot_to_resource(doc_ref.get()),
        "approvers",
        user_fields,
    )

    return json.dumps(resource), 201, {
        "Content-Type": "application/json",
        "Location": resource["selfLink"],
        "ETag": base.etag(resource)
        }


def patch(id, representation):
    transaction = base.db.transaction()
    approver_reference = base.db.document("approvers/{}".format(id))

    @firestore.transactional
    def update_in_transaction(transaction, approver_reference, representation):
        approver_snapshot = approver_reference.get(transaction=transaction)
        if not approver_snapshot.exists:
            return "Not found", 404

        resource = base.canonical_resource(
            base.snapshot_to_resource(approver_snapshot), "approvers", user_fields
        )

        if 'If-Match' in request.headers:   # Only apply if resource has not changed
            if request.headers.get('If-Match') != base.etag(resource):
                return "Conflict", 409

        transaction.update(approver_reference, representation)
        return "Updated", 204

    return update_in_transaction(transaction, approver_reference, representation)


def delete(id):
    approver_reference = base.db.document("approvers/{}".format(id))
    approver_snapshot = approver_reference.get()
    if not approver_snapshot.exists:
        return "Not found", 404

    resource = base.canonical_resource(
        base.snapshot_to_resource(approver_snapshot), "approvers", user_fields
    )

    if 'If-Match' in request.headers:   # Only apply if resource has not changed
        if request.headers.get('If-Match') != base.etag(resource):
            return "Conflict", 409

    approver_reference.delete()
    return "Deleted", 204
