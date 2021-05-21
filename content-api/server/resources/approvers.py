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

    return json.dumps(representations_list)


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

    return json.dumps(resource)


def insert(representation):
    resource = {"kind": "approvers"}
    for field in user_fields:
        resource[field] = representation.get(field, None)

    doc_ref = base.db.collection("approvers").document()
    doc_ref.set(resource)

    return "Created", 201


def patch(id, representation):
    approver_reference = base.db.document("approvers/{}".format(id))
    approver_snapshot = approver_reference.get()
    if not approver_snapshot.exists:
        return "Not found", 404

    changed_fields = []
    for field in user_fields:
        if field in representation:
            changed_fields.append(field)

    approver_reference.set(representation, merge=changed_fields)

    return "OK", 200


def delete(id):
    approver_reference = base.db.document("approvers/{}".format(id))
    approver_snapshot = approver_reference.get()
    if not approver_snapshot.exists:
        return "Not found", 404

    approver_reference.delete()
    return "", 204
