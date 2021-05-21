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


user_fields = ['name', 'email', 'mailing_address']


def list():
    donors_collection = base.db.collection('donors')
    representations_list = []
    for donor in donors_collection.stream():
        resource = donor.to_dict()
        resource['id'] = donor.id
        resource['timeCreated'] = donor.create_time.rfc3339()
        resource['updated'] = donor.update_time.rfc3339()
        representations_list.append(base.canonical_resource(resource, 'donors', user_fields))
    
    return json.dumps(representations_list)


def get(id):
    donor_reference = base.db.document('donors/{}'.format(id))
    donor_snapshot = donor_reference.get()
    if not donor_snapshot.exists:
        return 'Not found', 404
    
    resource = donor_snapshot.to_dict()
    resource['id'] = donor_snapshot.id
    resource['timeCreated'] = donor_snapshot.create_time.rfc3339()
    resource['updated'] = donor_snapshot.update_time.rfc3339()

    resource = base.canonical_resource(resource, 'donors', user_fields)

    return json.dumps(resource)


def insert(representation):
    resource = {'kind': 'donors'}
    for field in user_fields:
        resource[field] = representation.get(field, None)
    
    doc_ref = base.db.collection('donors').document()
    doc_ref.set(resource)

    return 'Created', 201


def patch(id, representation):
    donor_reference = base.db.document('donors/{}'.format(id))
    donor_snapshot = donor_reference.get()
    if not donor_snapshot.exists:
        return 'Not found', 404

    changed_fields = []
    for field in user_fields:
        if field in representation:
            changed_fields.append(field)

    donor_reference.set(representation, merge=changed_fields)

    return 'OK', 200


def delete(id):
    donor_reference = base.db.document('donors/{}'.format(id))
    donor_snapshot = donor_reference.get()
    if not donor_snapshot.exists:
        return 'Not found', 404

    donor_reference.delete()
    return '', 204
