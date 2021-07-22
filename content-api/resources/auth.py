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

from main import g
from resources import methods
from data import cloud_firestore as db


def allowed(operation, resource_kind, representation):
    email = g.get("verified_email", None)
    if email is None:
        return False

    if operation == 'POST':
        if resource_kind in ["approvers", "campaigns", "causes"]:
            matching_approvers = db.list_matching(
                resource_kind, methods.resource_fields[resource_kind], "email",  email
            )
            return len(matching_approvers) > 0

        elif resource_kind in ["donations"]:
            matching_donors = db.list_matching(
                "donors", methods.resource_fields[resource_kind], "email",  email
            )
            if len(matching_donors) > 0:
                donor_id = matching_donors[0]["id"]
                return donor_id == representation["donor"]
            else:
                return False

    else:
        return True    # TODO: other operations

