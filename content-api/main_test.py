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
import os
import pytest

import google.oauth2.id_token
import google.auth.transport.requests

import main
from resources import methods


kinds = [key for key in methods.resource_fields]

request = google.auth.transport.requests.Request()
audience = os.environ.get("TEST_API_SERVER_URL", "https://example.com")
id_token = google.oauth2.id_token.fetch_id_token(request, audience)
if id_token is not None:
    headers = {"Authorization": "Bearer {}".format(id_token)}
else:
    headers = {}


@pytest.fixture
def client():
    return main.app.test_client()


# Can we list every kind of resource?
def test_list_with_authentication(client):
    for kind in kinds:
        r = client.get("/{}".format(kind), headers=headers)
        assert r.status_code == 200
        assert r.headers.get("Content-Type") == "application/json"
        payload = json.loads(r.data)
        assert type(payload) == list


def test_list_without_authentication(client):
    for kind in kinds:
        r = client.get("/{}".format(kind))
        if kind in ["approvers", "donations"]:
            assert r.status_code == 403  # Resource requires authentication
        else:
            assert r.status_code == 200
            assert r.headers.get("Content-Type") == "application/json"
            payload = json.loads(r.data)
            assert type(payload) == list


# Create, fetch, modify, and delete resources
def test_lifecycle(client):
    for kind in kinds:
        if kind == "donations":  # Special case for later
            continue

        # Create a resource. Note that only the name field is mandatory
        representation = {"name": "test name"}
        r = client.post("/{}".format(kind), json=representation, headers=headers)
        assert r.status_code == 201
        resource = r.get_json(r.data)
        assert type(resource) == dict
        assert resource["name"] == representation["name"]

        # Check that the id is in the list response
        etag, _ = r.get_etag()
        id = resource["id"]
        r = client.get("/{}".format(kind), headers=headers)
        assert r.status_code == 200
        payload = r.get_json(r.data)
        found = False
        for item in payload:
            if item["id"] == id:
                found = True
                break
        assert found

        # Update only if same etag, given wrong etag
        representation = {"name": "changed name"}
        r = client.patch(
            "/{}/{}".format(kind, id),
            json=representation,
            headers={
                "If-Match": "wrong data",
                "Authorization": "Bearer {}".format(id_token),
            },
        )
        assert r.status_code == 409

        # Update only if same etag, given right etag
        representation = {"name": "changed name"}
        r = client.patch(
            "/{}/{}".format(kind, id),
            json=representation,
            headers={"If-Match": etag, "Authorization": "Bearer {}".format(id_token)},
        )
        assert r.status_code == 201
        resource = r.get_json(r.data)
        assert type(resource) == dict
        assert resource["name"] == representation["name"]

        # Fetch updated resource
        r = client.get("/{}/{}".format(kind, id), headers=headers)
        assert r.status_code == 200
        resource = r.get_json(r.data)
        assert type(resource) == dict
        assert resource["name"] == representation["name"]
        new_etag, _ = r.get_etag()

        # Try to delete, given wrong etag
        r = client.delete(
            "/{}/{}".format(kind, id),
            headers={
                "If-Match": "wrong",
                "Authorization": "Bearer {}".format(id_token),
            },
        )
        assert r.status_code == 409

        # Try to delete, given correct etag
        r = client.delete(
            "/{}/{}".format(kind, id),
            headers={
                "If-Match": new_etag,
                "Authorization": "Bearer {}".format(id_token),
            },
        )
        assert r.status_code == 204

        # Try to fetch deleted resource
        r = client.get("/{}/{}".format(kind, id), headers=headers)
        assert r.status_code == 404


# Create a campaign and donor, and then a donation for them
def test_donation(client):
    # Create a campaign
    campaign_representation = {"name": "test campaign"}
    r = client.post(
        "/{}".format("campaigns"), json=campaign_representation, headers=headers
    )
    assert r.status_code == 201
    campaign = r.get_json(r.data)
    assert type(campaign) == dict
    assert campaign["name"] == campaign_representation["name"]

    # Create a donor
    donor_representation = {"name": "test donor"}
    r = client.post("/{}".format("donors"), json=donor_representation, headers=headers)
    assert r.status_code == 201
    donor = r.get_json(r.data)
    assert type(donor) == dict
    assert donor["name"] == donor_representation["name"]

    # Create the only donation for that campaign or donor
    donation_representation = {
        "campaign": campaign["id"],
        "donor": donor["id"],
        "amount": 50,
    }
    r = client.post(
        "/{}".format("donations"), json=donation_representation, headers=headers
    )
    assert r.status_code == 201
    donation = r.get_json(r.data)
    assert type(donation) == dict
    assert donation["campaign"] == donation_representation["campaign"]
    assert donation["donor"] == donation_representation["donor"]

    # List of donations to campaign should have exactly one element
    r = client.get("/campaigns/{}/donations".format(campaign["id"]), headers=headers)
    assert r.status_code == 200
    assert r.headers.get("Content-Type") == "application/json"
    payload = json.loads(r.data)
    assert type(payload) == list
    assert len(payload) == 1
    resource = payload[0]
    assert resource["amount"] == 50
    assert resource["campaign"] == campaign["id"]
    assert resource["donor"] == donor["id"]

    # List of donations from donor should have exactly one element
    r = client.get("/donors/{}/donations".format(donor["id"]), headers=headers)
    assert r.status_code == 200
    assert r.headers.get("Content-Type") == "application/json"
    payload = json.loads(r.data)
    assert type(payload) == list
    assert len(payload) == 1
    resource = payload[0]
    assert resource["amount"] == 50
    assert resource["campaign"] == campaign["id"]
    assert resource["donor"] == donor["id"]

    # Clean up the three new resource
    r = client.delete("/donations/{}".format(donation["id"]), headers=headers)
    assert r.status_code == 204
    r = client.delete("/campaigns/{}".format(campaign["id"]), headers=headers)
    assert r.status_code == 204
    r = client.delete("/donors/{}".format(donor["id"]), headers=headers)
    assert r.status_code == 204
