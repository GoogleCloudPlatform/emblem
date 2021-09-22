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


""" Test that authenticated non-approvers can perform allowed,
    and are prevented from performing disallowed, API operations. """

import json
import jwt
import os
import pytest

# Use unique testing prefixes with collection names
os.environ["EMBLEM_DB_ENVIRONMENT"] = "TEST"

import main
from data import cloud_firestore as db
from resources import methods


# Types of resources to test
KINDS = [key for key in methods.resource_fields]
EMAIL = ""  # Updated if id_token available
HEADERS = {}  # For authentication if ID_TOKEN in environment

TEST_DONORS = {}
TEST_DONATIONS = {}
TEST_CAMPAIGNS = {}
TEST_CAUSE = None

# Set auth headers from the ID_TOKEN if possible
id_token = os.environ.get("ID_TOKEN")
if id_token is not None:
    headers = {"Authorization": f"Bearer {id_token}"}

    # Seed the approvers collection with this user
    token_alg = jwt.get_unverified_header(id_token).get("alg", "RS256")
    info = jwt.decode(
        id_token, algorithms=[token_alg], options={"verify_signature": False}
    )

    if "email" in info:
        EMAIL = info["email"]


# Set up and tear down test DB entries
@pytest.fixture(scope="module", autouse=True)
def data():
    # To test for allowed and disallowed scenarios, we need donors
    # for both the authorized user and a different user, donations
    # for each of them, and separate campaigns managed by each of
    # them.

    global TEST_DONORS
    global TEST_DONATIONS
    global TEST_CAMPAIGNS
    global TEST_CAUSE

    # Create and remember test data

    # Create a cause
    TEST_CAUSE = db.insert(
        "causes",
        {
            "name": "Test cause",
            "description": "Test cause description",
            "imageUrl": "https://example.com/picture.png",
            "active": True,
        },
        ["name", "description", "imageUrl", "active"],
        host_url="https://example.com",
    )

    for email_address in [EMAIL, "nobody@example.com"]:
        # Create donors
        donor = db.insert(
            "donors",
            {
                "name": "Test approver",
                "email": email_address,
                "mailing_address": "123 Main St, Anytown USA",
            },
            ["name", "email", "mailing_address"],
            host_url="https://example.com",
        )
        TEST_DONORS[email_address] = donor

        # Create campaigns
        campaign = db.insert(
            "campaigns",
            {
                "name": f"{email_address}'s Campaign",
                "description": f"{email_address}'s Campaign Description",
                "cause": TEST_CAUSE["id"],
                "managers": [email_address],
                "goal": 1000000,
                "imageUrl": "https://example.com/picture.png",
                "active": True,
            },
            ["name", "description", "cause", "managers", "goal", "imageUrl", "active"],
            host_url="https://example.com",
        )
        TEST_CAMPAIGNS[email_address] = campaign

        # Create donations
        donation = db.insert(
            "donations",
            {
                "campaign": TEST_CAMPAIGNS[email_address]["id"],
                "donor": TEST_DONORS[email_address]["id"],
                "amount": 1000,
            },
            ["campaign", "donor", "amount"],
            host_url="https://example.com",
        )
        TEST_DONATIONS[email_address] = donation

    try:
        yield None
    except:
        pass  # Still need to clean up test data

    # Tear down test data
    db.delete("causes", TEST_CAUSE["id"], ["id"], None)
    for email_address in [EMAIL, "nobody@example.com"]:
        db.delete("donations", TEST_DONATIONS[email_address]["id"], ["id"], None)
        db.delete("donors", TEST_DONORS[email_address]["id"], ["id"], None)
        db.delete("campaigns", TEST_CAMPAIGNS[email_address]["id"], ["id"], None)


@pytest.fixture
def client():
    return main.app.test_client()


# List every kind of resource
@pytest.mark.skipif(id_token is None, reason="CI build not yet including auth token")
def test_list_with_authentication(client):

    # Should never work
    for kind in ["approvers"]:
        r = client.get(f"/{kind}", headers=headers)
        assert r.status_code == 403

    # Should always work
    for kind in ["campaigns", "causes"]:
        r = client.get(f"/{kind}", headers=headers)
        assert r.status_code == 200
        assert r.headers.get("Content-Type") == "application/json"
        payload = json.loads(r.data)
        assert type(payload) == list

    # Should always work, but only for certain records
    for kind in ["donors", "donations"]:
        r = client.get(f"/{kind}", headers=headers)
        assert r.status_code == 200
        assert r.headers.get("Content-Type") == "application/json"
        payload = json.loads(r.data)
        assert type(payload) == list

        for item in payload:
            if kind == "donors":
                assert item["id"] == TEST_DONORS[EMAIL]["id"]
            elif kind == "donations":
                assert item["id"] == TEST_DONATIONS[EMAIL]["id"]


# List every subresource (donations for donors and campaigns)
@pytest.mark.skipif(id_token is None, reason="CI build not yet including auth token")
def test_list_subresources_with_authentication(client):

    # Case: campaign where user with EMAIL is a manager
    campaign_id = TEST_CAMPAIGNS[EMAIL]["id"]
    r = client.get(f"/campaigns/{campaign_id}/donations", headers=headers)
    assert r.status_code == 200
    assert r.headers.get("Content-Type") == "application/json"
    payload = json.loads(r.data)
    assert type(payload) == list
    assert len(payload) == 1
    for item in payload:
        assert item["campaign"] == campaign_id

    # Case: campaign where user with EMAIL is NOT manager
    campaign_id = TEST_CAMPAIGNS["nobody@example.com"]["id"]
    r = client.get(f"/campaigns/{campaign_id}/donations", headers=headers)
    assert r.status_code == 200
    assert r.headers.get("Content-Type") == "application/json"
    payload = json.loads(r.data)
    assert type(payload) == list
    assert len(payload) == 0  # user EMAIL has no donations here

    # Case: see donors and donations for their own records
    donor_id = TEST_DONORS[EMAIL]["id"]
    r = client.get(f"/donors/{donor_id}/donations", headers=headers)
    assert r.status_code == 200
    assert r.headers.get("Content-Type") == "application/json"
    payload = json.loads(r.data)
    assert type(payload) == list
    assert len(payload) == 1  # user EMAIL has no donations here

    # Case: can't see donors and donations for others' records
    donor_id = TEST_DONORS["nobody@example.com"]["id"]
    r = client.get(f"/donors/{donor_id}/donations", headers=headers)
    assert r.status_code == 200
    assert r.headers.get("Content-Type") == "application/json"
    payload = json.loads(r.data)
    assert type(payload) == list
    assert len(payload) == 0  # user EMAIL has no donations here


@pytest.mark.skipif(id_token is None, reason="CI build not yet including auth token")
def test_insert_with_authentication(client):

    # Approvers should never work
    testapprover = {
        "name": "Should never get into DB",
        "email": "bad email @ bad domain",
        "active": True,
    }
    r = client.post(f"/approvers", headers=headers, json=testapprover)
    assert r.status_code == 403

    # Campaigns should only work for approvers, which test user is not
    r = client.post(f"/campaigns", headers=headers, json=TEST_CAMPAIGNS[EMAIL])
    assert r.status_code == 403

    # Causes should only work for approvers, which test user is not
    r = client.post(f"/causes", headers=headers, json=TEST_CAUSE)
    assert r.status_code == 403

    # Donors should work for donor == test user, otherwise not
    r = client.post(f"/donors", headers=headers, json=TEST_DONORS[EMAIL])
    assert r.status_code == 201
    assert r.headers.get("Content-Type") == "application/json"
    payload = json.loads(r.data)
    assert type(payload) == dict
    assert r.status_code == 201

    # Clean up new donor
    r = client.delete(f"/donors/{payload['id']}")

    # Fail to create a donor without the logged in user's email address
    r = client.post(f"/donors", headers=headers, json=TEST_DONORS["nobody@example.com"])
    assert r.status_code == 403

    # Donations should work for donor == test user, otherwise not
    r = client.post(f"/donations", headers=headers, json=TEST_DONATIONS[EMAIL])
    assert r.status_code == 201
    assert r.headers.get("Content-Type") == "application/json"
    payload = json.loads(r.data)
    assert type(payload) == dict

    # Clean up new donation
    r = client.delete(f"/donations/{payload['id']}")
    assert r.status_code == 204

    r = client.post(
        f"/donations", headers=headers, json=TEST_DONATIONS["nobody@example.com"]
    )
    assert r.status_code == 403


# Create a donor, and then a donation for them
@pytest.mark.skipif(id_token is None, reason="CI build not yet including auth token")
def test_donation(client):

    # Create a donor
    donor_representation = {"name": "test donor", "email": EMAIL}

    r = client.post("/donors", json=donor_representation, headers=headers)
    assert r.status_code == 201
    donor = r.get_json(r.data)
    assert type(donor) == dict
    assert donor["name"] == donor_representation["name"]
    assert donor["email"] == EMAIL

    # Create a donation for that campaign donor doesn't manage
    donation_representation = {
        "campaign": TEST_CAMPAIGNS["nobody@example.com"]["id"],
        "donor": donor["id"],
        "amount": 50,
    }

    r = client.post("/donations", json=donation_representation, headers=headers)
    assert r.status_code == 201
    donation = r.get_json(r.data)
    assert type(donation) == dict
    assert donation["campaign"] == donation_representation["campaign"]
    assert donation["donor"] == donation_representation["donor"]

    # Clean up the new resources
    r = client.delete("/donations/{}".format(donation["id"]), headers=headers)
    assert r.status_code == 204
    r = client.delete("/donors/{}".format(donor["id"]), headers=headers)
    assert r.status_code == 204
