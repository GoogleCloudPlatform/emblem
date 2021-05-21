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


from google.cloud import firestore


"""
    Utility functions and values that apply to every type of resource.
"""


# Reuse a global Firestore client to prevent repeated initializations
db = firestore.Client()


# Stored resources are dictionaries containing all user fields,
# such as name, and system generated values such as
# id, timeCreated, and updated values.
#
# They do not contain the resource kind or selfLink.
#
# This function returns a JSON representation of a stored
# resource, and inserts the resource kind, selfLink, and etag.
# 
# Values missing from the dictionary are treated as None (null
# in JSON).
def canonical_resource(resource, resource_kind, user_fields):
    representation = {
        'kind': resource_kind,
        'id': resource.get('id', None),
        'timeCreated': resource.get('timeCreated', None),
        'updated': resource.get('updated', None),
        'selfLink': '/{}/{}'.format(resource_kind, resource.get('id', None))
    }

    for field_name in user_fields:
        representation[field_name] = resource.get(field_name, None)

    return representation
