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
from google.cloud import firestore


def seed_approver(email):
    client = firestore.Client()

    approver = {
        "kind": "approvers",
        "email": email,
        "active": True,
        "name": "Seeded test user",
    }

    doc_ref = client.collection("approvers").document()
    doc_ref.set(approver)


parser = argparse.ArgumentParser(description='Seed a test "approver" resource')
parser.add_argument("email", help="email address of the seeded approver")

args = parser.parse_args()
email = args.email

seed_approver(email)

print("Approver with email {} added.".format(email))
