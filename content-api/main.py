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

from os import set_inheritable
from flask import Response, Flask, g, request
from flask_cors import CORS

from google.auth.transport import requests as reqs
from google.oauth2 import id_token

from resources import methods

from opentelemetry import propagate
from opentelemetry import trace

from opentelemetry.exporter.cloud_trace import CloudTraceSpanExporter
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.propagators.cloud_trace_propagator import CloudTraceOneWayPropagator
from opentelemetry.propagators.composite import CompositePropagator
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.sdk.trace import TracerProvider

provider = TracerProvider()
processor = BatchSpanProcessor(CloudTraceSpanExporter())
provider.add_span_processor(processor)

# Add the X-Cloud-Trace-Context propagator.
# Note: Because of the behavior of the XCTC 'force trace' bit, this will cause
# all downstream services to force tracing, resulting in larger than expected
# storage costs.
propagate.set_global_textmap(
    CompositePropagator(
        [
            propagate.get_global_textmap(),
            CloudTraceOneWayPropagator(),
        ]
    )
)

# Sets the global default tracer provider
trace.set_tracer_provider(provider)

resource = [
    "approvers",
    "campaigns",
    "causes",
    "donations",
    "donors",
]

app = Flask(__name__)

CORS(app, resources={r"/*": {"origins": "*"}})
FlaskInstrumentor().instrument_app(app)

# Check authentication and remember result in global request context
#
# If authentication is invalid, or operation is unauthorized,
# reject the request with 403 Forbidden. Otherwise, return None,
# and normal processing continues
@app.before_request
def check_user_authentication():
    g.verified_email = None

    auth = request.headers.get("Authorization", None)

    if auth is None:
        return

    if not auth.startswith("Bearer "):
        return

    token = auth[7:]  # Remove "Bearer: " prefix

    # Extract the email address from the token. Since there may be
    # two types of token provided (Firebase or Google OAuth2) and
    # failed verification raises an exception, need multiple
    # try/except blocks.

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

    if info is not None:  # Remember the email address throughout this request
        if "email" in info:
            g.verified_email = info["email"]

    return


# Resource collection methods


@app.route("/<resource_name>", methods=["GET"])
def handle_list(resource_name):
    if resource_name not in resource:
        return "Not found", 404
    return methods.list(resource_name)


@app.route("/<resource_name>/<id>/<subresource_name>", methods=["GET"])
def handle_list_subresource(resource_name, id, subresource_name):
    return methods.list_subresource(resource_name, id, subresource_name)


@app.route("/<resource_name>", methods=["POST"])
def handle_insert(resource_name):
    if resource_name not in resource:
        return "Not found", 404
    if not request.is_json:
        return "Unsupported media type", 415

    body = request.get_json(silent=True)
    if body is None:
        return "Bad request", 400

    return methods.insert(resource_name, body)


# Individual resource methods


@app.route("/<resource_name>/<id>", methods=["GET"])
def handle_get(resource_name, id):
    if resource_name not in resource:
        return "Not found", 404
    return methods.get(resource_name, id)


@app.route("/<resource_name>/<id>", methods=["DELETE"])
def handle_delete(resource_name, id):
    if resource_name not in resource:
        return "Not found", 404
    return methods.delete(resource_name, id)


@app.route("/<resource_name>/<id>", methods=["PATCH"])
def handle_patch(resource_name, id):
    if resource_name not in resource:
        return "Not found", 404
    if not request.is_json:
        return "Unsupported media type", 415

    body = request.get_json(silent=True)
    if body is None:
        return "Bad request", 400

    return methods.patch(resource_name, id, body)


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=8080, debug=True)
