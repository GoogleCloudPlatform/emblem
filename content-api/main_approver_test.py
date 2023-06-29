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


""" Test that approvers can perform any API operation. """

import json
import os
import pytest

from google.auth.transport import requests as reqs
from google.oauth2 import id_token

# Use unique testing prefixes with collection names
os.environ["EMBLEM_DB_ENVIRONMENT"] = "TEST"

import main
from data import cloud_firestore as db
from resources import methods


# Types of resources to test
KINDS = [key for key in methods.resource_fields]
EMAIL = ""  # Updated if id_token available

TEST_APPROVER = None

# Create the authorization header for a test user
token = os.environ.get("ID_TOKEN")
if token is not None:
    headers = {"Authorization": f"Bearer {token}"}

    info = None
    try:
        info = id_token.verify_firebase_token(token, reqs.Request())
    except ValueError:
        pass

    try:
        if info is None:
            info = id_token.verify_oauth2_token(token, reqs.Request())
    except ValueError:
        pass

    # Seed the approvers collection with this user

    if info is not None and "email" in info:
        EMAIL = info["email"]
else:
    headers = {}


# Set up and tear down test DB entries
@pytest.fixture(scope="module", autouse=True)
def data():
    global TEST_APPROVER

    # We need the current ID_TOKEN to be an approver
    TEST_APPROVER = db.insert(
        "approvers",
        {"name": "Testing approver", "email": EMAIL, "active": True},
        ["name", "email", "active"],
        host_url="https://example.com/",
    )

    try:
        yield None
    except:
        pass

    # Tear down test data
    db.delete(
        "approvers", TEST_APPROVER["id"], ["id"], None, host_url="https://example.com/"
    )


@pytest.fixture
def client():
    try:
        return main.app.test_client()
    except Exception as e:
        assert False, f"Exception raised: {e}"


# List every kind of resource
@pytest.mark.skipif(id_token is None, reason="CI build not yet including auth token")
def test_list_with_authentication(client):
    try:
        for kind in KINDS:
            r = client.get(f"/{kind}", headers=headers)
            assert r.status_code == 200
            assert r.headers.get("Content-Type") == "application/json"
            payload = json.loads(r.data)
            assert type(payload) == list
    except Exception as e:
        assert False, f"Exception raised: {e}"


# Create, fetch, modify, and delete resources
@pytest.mark.skipif(id_token is None, reason="CI build not yet including auth token")
def test_lifecycle(client):
    try:
        for kind in KINDS:
            if kind == "donations":  # Special case for later
                continue

            # Create a resource. Note that only the name field is usually mandatory
            representation = {"name": "test name"}
            if kind == "donors":
                representation["email"] = "nobody@example.com"
            r = client.post(f"/{kind}", json=representation, headers=headers)
            assert r.status_code == 201
            resource = r.get_json(r.data)
            assert type(resource) == dict
            assert resource["name"] == representation["name"]

            etag, _ = r.get_etag()
            id = resource["id"]

            # Check that the id is in the list response for that resource kind
            r = client.get(f"/{kind}", headers=headers)
            assert r.status_code == 200
            payload = r.get_json(r.data)
            assert id in [item["id"] for item in payload]

            # Update only if same etag, given wrong etag
            representation = {"name": "changed name"}
            patch_headers = headers.copy()
            patch_headers["If-Match"] = "wrong etag"
            r = client.patch(
                f"/{kind}/{id}",
                json=representation,
                headers=patch_headers,
            )
            assert r.status_code == 409

            # Update only if same etag, given right etag
            representation = {"name": "changed name"}
            patch_headers = headers.copy()
            patch_headers["If-Match"] = etag

            r = client.patch(
                f"/{kind}/{id}",
                json=representation,
                headers=patch_headers,
            )
            assert r.status_code == 201
            resource = r.get_json(r.data)
            assert type(resource) == dict
            assert resource["name"] == representation["name"]

            # Fetch updated resource
            r = client.get(f"/{kind}/{id}", headers=headers)
            assert r.status_code == 200
            resource = r.get_json(r.data)
            assert type(resource) == dict
            assert resource["name"] == representation["name"]

            new_etag, _ = r.get_etag()

            # Try to delete, given old etag
            delete_headers = headers.copy()
            delete_headers["If-Match"] = etag
            r = client.delete(
                f"/{kind}/{id}",
                headers=delete_headers,
            )
            assert r.status_code == 409

            # Try to delete, given correct etag
            delete_headers = headers.copy()
            delete_headers["If-Match"] = new_etag
            r = client.delete(
                f"/{kind}/{id}",
                headers=delete_headers,
            )
            assert r.status_code == 204

            # Try to fetch deleted resource
            r = client.get(f"/{kind}/{id}", headers=headers)
            assert r.status_code == 404
    except Exception as e:
        assert False, f"Exception raised: {e}"


# Create a campaign and donor, and then a donation for them
@pytest.mark.skipif(id_token is None, reason="CI build not yet including auth token")
def test_donation(client):
    try:
        # Create a campaign
        campaign_representation = {"name": "test campaign"}
        r = client.post("/campaigns", json=campaign_representation, headers=headers)
        assert r.status_code == 201
        campaign = r.get_json(r.data)
        assert type(campaign) == dict
        assert campaign["name"] == campaign_representation["name"]

        # Create a donor
        donor_representation = {"name": "a repeat donor", "email": EMAIL}
        r = client.post("/donors", json=donor_representation, headers=headers)
        assert r.status_code == 201
        donor = r.get_json(r.data)
        assert type(donor) == dict
        assert donor["name"] == donor_representation["name"]
        assert donor["email"] == EMAIL

        # Create the only donation for that campaign or donor
        donation_representation = {
            "campaign": campaign["id"],
            "donor": donor["id"],
            "amount": 50,
        }
        r = client.post("/donations", json=donation_representation, headers=headers)
        assert r.status_code == 201
        donation = r.get_json(r.data)
        assert type(donation) == dict
        assert donation["campaign"] == donation_representation["campaign"]
        assert donation["donor"] == donation_representation["donor"]

        # List of donations to campaign should have exactly one element
        r = client.get(
            "/campaigns/{}/donations".format(campaign["id"]), headers=headers
        )
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
    except Exception as e:
        assert False, f"Exception raised: {e}"
