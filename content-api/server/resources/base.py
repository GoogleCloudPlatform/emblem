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


import hashlib
import json

from google.cloud import firestore

import main


"""
    Utility functions and values that apply to every type of resource.

    db - exported value representing a Firestore Client.

    canonical_resource - given a stored resource, add standard fields that
        are derived, rather than stored, such as timestamps and etags.
"""


# Reuse a global Firestore client to prevent repeated initializations
db = firestore.Client()


def snapshot_to_resource(snapshot):
    resource = snapshot.to_dict()
    resource["id"] = snapshot.id
    resource["timeCreated"] = snapshot.create_time.rfc3339()
    resource["updated"] = snapshot.update_time.rfc3339()

    return resource


# Stored resources are dictionaries containing all user fields,
# such as name, and system generated values such as
# id, timeCreated, and updated values.
#
# They do not contain the resource kind or selfLink.
#
# This function returns a JSON representation of a resource
# dictionary, and inserts the resource kind, selfLink, and etag.
#
# Values missing from the dictionary are treated as None (null
# in JSON).
def canonical_resource(resource, resource_kind, user_fields, host_url=""):
    location = "{}{}/{}".format(main.request.host_url, resource_kind, resource.get("id", ""))
    # Environment may use http: scheme internally, but externally should be https:
    if location.startswith("http:"):
        location = location.replace("http:", "https:")

    representation = {
        "kind": resource_kind,
        "id": resource.get("id", None),
        "timeCreated": resource.get("timeCreated", None),
        "updated": resource.get("updated", None),
        "selfLink": location,
    }

    for field_name in user_fields:
        representation[field_name] = resource.get(field_name, None)

    representation["etag"] = hashlib.sha256(json.dumps(representation).encode()).hexdigest()
    return representation
