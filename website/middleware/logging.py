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


"""The Emblem website-specific logging utility.
    
    Usage:
        from middleware.logging import log
        log("A message", severity="DEBUG")

    Version: 0.1 - Initial minimal release.
"""

import json
import re
import requests

from flask import request


# Query the metadata server on initialization to get the project number used
# to identify the trace identifier that helps group log entries by http request.
metadata_url = "http://metadata.google.internal/computeMetadata/v1"
try:
    PROJECT_ID = requests.get(f"{metadata_url}/project/project-id").text
except Exception as e:
    print(f"Failed to get project id from metadata server: {e}")
    PROJECT_ID = "-- MISSING PROJECT ID --"


def log(message, severity="DEFAULT", **kwargs):
    """Log a message and related information (structured logging) to stdout.

    Args:
        message (str): the text to be logged
        severity (str): the severity of the log entry. The underlying Google
            logging API will recognize the standard values documented at
            https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry#LogSeverity

    Keyword Args:
        Almost any additional labeled information desired in the log. Some keywords
        are reserved, and will be ignored if provided, including the following:
            - logging.googleapis.com/trace

    Returns:
        Nothing
    """

    logStruct = {"message": message, "severity": severity}

    if request:  # Usually will be in a request context, but not always
        trace = request.headers.get("X-Cloud-Trace-Context")
        if trace is not None:
            trace = re.split(r"\W+", trace)[0]
            logStruct[
                "logging.googleapis.com/trace"
            ] = f"projects/{PROJECT_ID}/traces/{trace}"

    for key in kwargs:
        if key not in logStruct:
            logStruct[key] = kwargs[key]

    print(json.dumps(logStruct))
