# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


"""
    Stored session management.
    
    Create, read, update, or delete data for a stored session.

    Examples:
        from middleware import session

        session_id = session.create({"name": "J. Doe", "email": "jdoe@example.com"})

        info = session.read(session_id)
        info["country"] = "US"
        session.update(session_id, info)

        session.delete(session_id)

    The session data will be stored in Google Cloud Storage. A bucket must already
    exist for this use, and the name of the bucket provided in the environment
    variable EMBLEM_SESSION_BUCKET. No other objects should be in this bucket
    as they might conflict with the objects managed by this module.

    Note that the code that calls these methods is responsible for managing
    a cookie with the session ID in the user's web browser.
"""


import json
import os
import uuid

from google.cloud import storage

from middleware.logging import log


# Initialize data that's not specific to an http request.
session_bucket_name = os.environ.get("EMBLEM_SESSION_BUCKET")
if session_bucket_name is None:
    log("Could not initialize session module.", severity="ERROR")
    raise Exception("Environment variable EMBLEM_SESSION_BUCKET is required")

# Create a storage client that will be used over multiple requests
BUCKET = storage.Client().bucket(session_bucket_name)


def create(session_data):
    """Create a stored session containing the provided data.

    Args:
        session_data: the data to be saved for this session. It can be any data
            type that can be serialized and then deserialized with the Python
            standard json module.

    Returns:
        A string containing an identifier for the created session, or None if
        the session store was not created.
    """

    session_id = uuid.uuid4().hex
    try:
        contents = json.dumps(session_data)
    except Exception as e:
        log(f"Failed to convert session data to JSON: {e}", severity="ERROR")
        return None

    try:
        blob = storage.blob.Blob(session_id, BUCKET)
        blob.upload_from_string(contents, content_type="application/json")
    except Exception as e:
        log(f"Failed to save session data to cloud storage: {e}", severity="ERROR")
        return None

    return session_id


def read(session_id):
    """Return the data previously saved for the specified session id.

    Args:
        session_id (str): the unique identifier of the session store.

    Returns:
        The stored session data if it exists and can be retrieved,
        None otherwise.
    """

    try:
        blob = storage.blob.Blob(session_id, BUCKET)
        session_data = blob.download_as_string()
    except Exception as e:
        log(f"Failed to read session data from cloud storage: {e}", severity="ERROR")
        return None

    try:
        contents = json.loads(session_data)
    except Exception as e:
        log(f"Failed to convert session data to JSON: {e}", severity="ERROR")
        return None

    return contents


def update(session_id, session_data):
    """Update an existing stored session to the newly provided session_data. The
        previous stored data will be overwritten.

    Args:
        session_id (str): the unique identifier of the session store.
        session_data: the data to be saved for this session. It can be any data
            type that can be serialized and then deserialized with the Python
            standard json module.

    Returns:
        True if the update succeeds, False otherwise.
    """

    try:
        contents = json.dumps(session_data)
    except Exception as e:
        log(f"Failed to convert session data to JSON: {e}", severity="ERROR")
        return False

    try:
        blob = storage.blob.Blob(session_id, BUCKET)
        blob.upload_from_string(contents, content_type="application/json")
    except Exception as e:
        log(f"Failed to save session data to cloud storage: {e}", severity="ERROR")
        return False

    return True


def delete(session_id):
    """Permanently deletes the data previously saved for the specified session id.

    Args:
        session_id (str): the unique identifier of the session store.

    Returns:
        True if successful, False otherwise.
    """

    try:
        blob = storage.blob.Blob(session_id, BUCKET)
        blob.delete()
    except Exception as e:
        log(
            f"Failed to delete stored session from cloud storage: {e}", severity="ERROR"
        )
        return False

    return True
