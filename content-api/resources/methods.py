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

from main import g, request
from data import cloud_firestore as db
from resources import base


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


def list(resource_kind):
    if resource_kind not in resource_fields:
        return "Not found", 404

    results = db.list(resource_kind, resource_fields[resource_kind])
    return json.dumps(results), 200, {"Content-Type": "application/json"}


def list_subresource(resource_kind, id, subresource_kind):
    if resource_kind not in resource_fields or subresource_kind not in resource_fields:
        return "Not found", 404

    resource = db.fetch(resource_kind, id, resource_fields[resource_kind])
    if resource is None:
        return "Not found", 404

    results = db.list_matching(
        subresource_kind,
        resource_fields[subresource_kind],
        resource_kind[:-1],  # Subresource field for singular resource_kind
        id,  # Value must match parent id
    )

    return json.dumps(results), 200, {"Content-Type": "application/json"}


def get(resource_kind, id):
    if resource_kind not in resource_fields:
        return "Not found", 404

    result = db.fetch(resource_kind, id, resource_fields[resource_kind])
    if result is None:
        return "Not found", 404

    return (
        json.dumps(result),
        200,
        {"Content-Type": "application/json", "ETag": base.etag(result)},
    )


def insert(resource_kind, representation):
    if resource_kind not in resource_fields:
        return "Not found", 404

    if resource_kind == 'approvers':
        email = g.get("verified_email", None)
        matching_approvers = db.list_matching(
            "approvers",
            resource_fields["approvers"],
            "email", email)
        if not matching_approvers:
            return "Forbidden", 403

    db.insert(resource_kind, representation, resource_fields[resource_kind])

    return (
        json.dumps(resource),
        201,
        {
            "Content-Type": "application/json",
            "Location": resource["selfLink"],
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
