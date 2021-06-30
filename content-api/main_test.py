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
import pytest

import main
from resources import methods


kinds = [key for key in methods.resource_fields]


@pytest.fixture
def client():
    main.app.testing = True
    return main.app.test_client()


def test_list(client):
    for kind in kinds:
        r = client.get("/{}".format(kind))
        assert r.status_code == 200
        assert r.headers.get("Content-Type") == "application/json"
        payload = json.loads(r.data)
        assert type(payload) == list


# Create, fetch, modify, and delete resources
def test_lifecycle(client):
    for kind in kinds:
        if kind == "donations":     #Special case for later
            continue

        # Create a resource. Note that only name is mandatory
        representation = {"name": "test name"}
        r = client.post("/{}".format(kind), json=representation)
        assert r.status_code == 201
        resource = r.get_json(r.data)
        assert type(resource) == dict
        assert resource["name"] == representation["name"]

        etag, _ = r.get_etag()
        id = resource["id"]

        # Update only if same etag, given wrong etag
        representation = {"name": "changed name"}
        r = client.patch(
            "/{}/{}".format(kind, id),
            json=representation,
            headers={"If-Match": "wrong data"}
        )
        assert r.status_code == 409

        # Update only if same etag, given right etag
        representation = {"name": "changed name"}
        r = client.patch(
            "/{}/{}".format(kind, id),
            json=representation,
            headers={"If-Match": etag}
        )
        assert r.status_code == 201
        resource = r.get_json(r.data)
        assert type(resource) == dict
        assert resource["name"] == representation["name"]

        # Fetch updated resource
        r = client.get("/{}/{}".format(kind, id))
        assert r.status_code == 200
        resource = r.get_json(r.data)
        assert type(resource) == dict
        assert resource["name"] == representation["name"]
        new_etag, _ = r.get_etag()

        # Try to delete, given wrong etag
        r = client.delete(
            "/{}/{}".format(kind, id),
            headers={"If-Match": "wrong"}
        )
        assert r.status_code == 409

        # Try to delete, given correct etag
        r = client.delete(
            "/{}/{}".format(kind, id),
            headers={"If-Match": new_etag}
        )
        assert r.status_code == 204

        # Try to fetch deleted resource
        r = client.get("/{}/{}".format(kind, id))
        assert r.status_code == 404
