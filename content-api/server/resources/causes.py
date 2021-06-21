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
    Manages API operations for the Causes resource type, implementing
    standard methods:

        list    Return all causes
        get     Return a single cause
        insert  Create a new cause
        patch   Update a cause
        delete  Remove a cause

    Includes these standard properties:

        kind        "causes"
        id          unique system generated identifier
        timeCreated timestamp; when this was created
        updated     timestamp; when this was last updated
        selfLink    the path of the URI for this resource

    Includes cause specific properties:

        name        the display name of the cause
        description string describing the purpose of the cause
        imageUrl    string containing URL of an image to display
        active      boolean; whether this person can currently approve

    All properties are strings, unless otherwise noted in the description.

    Since JSON does not have a date or datetime format, all timestamps are
    strings in RFC 3339 format for UTC, as in YYYY-MM-DDTHH:MM:SS.ffffffZ.
"""


import json
from google.cloud import firestore

from main import request
from resources import base


user_fields = ["name", "description", "imageUrl", "active"]


def list():
    causes_collection = base.db.collection("causes")
    representations_list = []
    for cause in causes_collection.stream():
        resource = cause.to_dict()
        resource["id"] = cause.id
        resource["timeCreated"] = cause.create_time.rfc3339()
        resource["updated"] = cause.update_time.rfc3339()
        representations_list.append(
            base.canonical_resource(resource, "causes", user_fields)
        )

    return json.dumps(representations_list), 200, {"Content-Type": "application/json"}


def get(id):
    cause_reference = base.db.document("causes/{}".format(id))
    cause_snapshot = cause_reference.get()
    if not cause_snapshot.exists:
        return "Not found", 404

    resource = cause_snapshot.to_dict()
    resource["id"] = cause_snapshot.id
    resource["timeCreated"] = cause_snapshot.create_time.rfc3339()
    resource["updated"] = cause_snapshot.update_time.rfc3339()

    resource = base.canonical_resource(resource, "causes", user_fields)

    return json.dumps(resource), 200, {
        "Content-Type": "application/json",
        "ETag": base.etag(resource)
    }


def insert(representation):
    resource = {"kind": "causes"}
    for field in user_fields:
        resource[field] = representation.get(field, None)

    doc_ref = base.db.collection("causes").document()
    doc_ref.set(resource)

    resource = base.canonical_resource(
        base.snapshot_to_resource(doc_ref.get()),
        "causes",
        user_fields,
    )

    return json.dumps(resource), 201, {
        "Content-Type": "application/json",
        "Location": resource["selfLink"],
        "ETag": base.etag(resource)
        }


def patch(id, representation):
    transaction = base.db.transaction()
    cause_reference = base.db.document("causes/{}".format(id))

    @firestore.transactional
    def update_in_transaction(transaction, cause_reference, representation):
        cause_snapshot = cause_reference.get(transaction=transaction)
        if not cause_snapshot.exists:
            return "Not found", 404

        resource = base.canonical_resource(
            base.snapshot_to_resource(cause_snapshot), "causes", user_fields
        )

        if 'If-Match' in request.headers:   # Only apply if resource has not changed
            if request.headers.get('If-Match') != base.etag(resource):
                return "Conflict", 409

        transaction.update(cause_reference, representation)
        return "Updated", 204

    return update_in_transaction(transaction, cause_reference, representation)


def delete(id):
    cause_reference = base.db.document("causes/{}".format(id))
    cause_snapshot = cause_reference.get()
    if not cause_snapshot.exists:
        return "Not found", 404

    resource = base.canonical_resource(
        base.snapshot_to_resource(cause_snapshot), "causes", user_fields
    )

    if 'If-Match' in request.headers:   # Only apply if resource has not changed
        if request.headers.get('If-Match') != base.etag(resource):
            return "Conflict", 409

    cause_reference.delete()
    return "Deleted", 204
