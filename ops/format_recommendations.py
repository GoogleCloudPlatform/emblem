# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


from datetime import datetime
import fileinput
import json
import os
import sys


# Helper function to get a principal email from a recommendation
def __get_email(item):
    overview = item["content"]["overview"]
    
    email = overview["member"]
    email = email[email.index(':') + 1:]

    return email


# Helper function to get a recommendation ID from a recommendation
def __get_rec_id(item):
    rec_id = item["name"]
    rec_id = rec_id[rec_id.rindex('/') + 1:]

    return rec_id

project_id = os.getenv('GOOGLE_CLOUD_PROJECT')

stdin = "".join(fileinput.input())
suggestions = json.loads(stdin)

# Sort suggestions
suggestions.sort(key=lambda item: __get_email(item))

# {Count, Print out} active suggestions
suggestion_count = 0
for item in suggestions:

    # Ignore non-ACTIVE recommendations
    state = item["stateInfo"]["state"]
    if state != 'ACTIVE':
        continue

    # Get details
    suggestion_count += 1
    email = __get_email(item)
    rec_id = __get_rec_id(item)
    
    removed_role = item["content"]["overview"]["removedRole"]
    etag = item["etag"].strip("\"")


    last_updated = datetime.strptime(
        item["lastRefreshTime"],
        '%Y-%m-%dT%H:%M:%SZ'
    )
    last_updated_str = datetime.strftime(
        last_updated,
        '%b %d %Y, %I %M %p'
    )

    # Print details
    print("---------------------------------------------")
    print("ID: " + rec_id)
    print("Email: " + email)
    print("Role removed: " + removed_role)
    print("Last Updated: " + last_updated_str)

    # Print gcloud command
    print("To mark this recommendation addressed, use the following command:")
    print(f"\ngcloud recommender recommendations mark-succeeded {rec_id} \\")
    print(f"\t--project {project_id} \\")
    print(f"\t--location global \\")
    print(f"\t--recommender google.iam.policy.Recommender \\")
    print(f"\t--etag \"\\\"{etag}\\\"\"")


# Return a non-zero exit code if any suggestions were yielded
sys.exit(suggestion_count)
