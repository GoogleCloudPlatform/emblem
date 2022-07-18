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

import os
import json


def seed_database(content):

    client = firestore.Client(project=os.environ.get("GOOGLE_CLOUD_PROJECT"))
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


with open("sample_data.json", "r") as f:
    seed_content = json.load(f)

seed_database(seed_content)
