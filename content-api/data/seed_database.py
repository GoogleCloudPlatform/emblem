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

import argparse
import json
from google.cloud import firestore


def seed_approver(email):
    client = firestore.Client()
    print("Seeding approver into Google Cloud Project '{}'.".format(client.project))

    approver = {
        "kind": "approvers",
        "email": email,
        "active": True,
        "name": "Seeded test user",
    }

    doc_ref = client.collection("approvers").document()
    doc_ref.set(approver)


def seed_database(content):

    client = firestore.Client()
    print("Seeding data into Google Cloud Project '{}'.".format(client.project))
    print("This may take a few minutes...")
    for item in content:
        doc_ref = client.collection(item["collection"]).document(item["id"])
        try:
            doc_ref.set(item["data"])
        except Exception as e:
            print(f"Seeding failed: {e}")
            print("Check logs for more info.")

    print("Successfully seeded database")


def unseed_database():

    client = firestore.Client()
    print("Deleting seed data from Google Cloud Project '{}'.".format(client.project))
    print("This may take a few minutes...")
    # Delete all objects from seed data
    collections = ["approvers", "campaigns", "causes", "donations", "donors"]
    for coll in collections:
        coll_ref = client.collection(coll)
        docs = coll_ref.list_documents()
        for doc in docs:
            doc.delete()

    print("Finished unseeding database")


parser = argparse.ArgumentParser(description="Seed or unseed firestore database")
parser.add_argument("seed_or_unseed")
parser.add_argument("email", help="email for approver", nargs="?")

args = parser.parse_args()

if args.seed_or_unseed == "unseed":
    unseed_database()
elif args.seed_or_unseed == "seed":
    if not args.email:
        print("email must be provided as the second arg")
    else:
        seed_approver(args.email)
        with open("sample_data.json", "r") as f:
            seed_content = json.load(f)
        seed_database(seed_content)
else:
    print('first arg must be specified as "seed" or "unseed"')
