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
from google.cloud import firestore

from main import request
from resources import base


resource_fields = {
    "approvers": ["name", "email", "active"],
    "campaigns": ["name", "description", "cause", "managers", "goal", "imageUrl", "active"],
    "causes": ["name", "description", "imageUrl", "active"],
    "donations": ["campaign", "donor", "amount"],
    "donors": ["name", "email", "mailing_address"],
}


def list(resource_kind):
    resources_collection = base.db.collection(resource_kind)
    representations_list = []
    for resource_ref in resources_collection.stream():
        resource = resource_ref.to_dict()
        resource["id"] = resource_ref.id
        resource["timeCreated"] = resource_ref.create_time.rfc3339()
        resource["updated"] = resource_ref.update_time.rfc3339()
        representations_list.append(
            base.canonical_resource(resource, resource_kind, resource_fields[resource_kind])
        )

    return json.dumps(representations_list), 200, {"Content-Type": "application/json"}


def get(resource_kind, id):
    resource_reference = base.db.document("{}/{}".format(resource_kind, id))
    resource_snapshot = resource_reference.get()
    if not resource_snapshot.exists:
        return "Not found", 404

    resource = resource_snapshot.to_dict()
    resource["id"] = resource_snapshot.id
    resource["timeCreated"] = resource_snapshot.create_time.rfc3339()
    resource["updated"] = resource_snapshot.update_time.rfc3339()

    resource = base.canonical_resource(resource, resource_kind, resource_fields[resource_kind])

    return json.dumps(resource), 200, {
        "Content-Type": "application/json",
        "ETag": base.etag(resource)
    }


def insert(resource_kind, representation):
    resource = {"kind": resource_kind}
    for field in resource_fields[resource_kind]:
        resource[field] = representation.get(field, None)

    doc_ref = base.db.collection(resource_kind).document()
    doc_ref.set(resource)

    resource = base.canonical_resource(
        base.snapshot_to_resource(doc_ref.get()),
        resource_kind,
        resource_fields[resource_kind],
    )

    return json.dumps(resource), 201, {
        "Content-Type": "application/json",
        "Location": resource["selfLink"],
        "ETag": base.etag(resource)
        }


def patch(resource_kind, id, representation):
    transaction = base.db.transaction()
    resource_reference = base.db.document("{}/{}".format(resource_kind, id))

    @firestore.transactional
    def update_in_transaction(transaction, resource_reference, representation):
        resource_snapshot = resource_reference.get(transaction=transaction)
        if not resource_snapshot.exists:
            return "Not found", 404

        resource = base.canonical_resource(
            base.snapshot_to_resource(resource_snapshot),
            resource_kind,
            resource_fields[resource_kind]
        )

        if 'If-Match' in request.headers:   # Only apply if resource has not changed
            if request.headers.get('If-Match') != base.etag(resource):
                return "Conflict", 409

        transaction.update(resource_reference, representation)

        for key in representation:
            if key in resource:
                resource[key] = representation[key]
                
        return json.dumps(resource), 201, {
            "Content-Type": "application/json",
            "Location": resource["selfLink"],
            "ETag": base.etag(resource)
        }


    return update_in_transaction(transaction, resource_reference, representation)


def delete(resource_kind, id):
    resource_reference = base.db.document("{}/{}".format(resource_kind, id))
    resource_snapshot = resource_reference.get()
    if not resource_snapshot.exists:
        return "Not found", 404

    resource = base.canonical_resource(
        base.snapshot_to_resource(resource_snapshot),
        resource_kind,
        resource_fields[resource_kind]
    )

    if 'If-Match' in request.headers:   # Only apply if resource has not changed
        if request.headers.get('If-Match') != base.etag(resource):
            return "Conflict", 409

    resource_reference.delete()
    return "", 204
