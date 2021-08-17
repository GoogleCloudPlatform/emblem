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

from flask import Flask, g, request

from google.auth.transport import requests as reqs
from google.oauth2 import id_token

from resources import methods, auth


resource = [
    "approvers",
    "campaigns",
    "causes",
    "donations",
    "donors",
]

app = Flask(__name__)


# Check authentication and remember result in global request context
#
# If authentication is invalid, or operation is unauthorized,
# reject the request with 403 Forbidden. Otherwise, return None,
# and normal processing continues
@app.before_request
def check_user_authentication():
    auth = request.headers.get("Authorization", None)
    if auth is None:
        return

    if not auth.startswith("Bearer "):
        return "Forbidden", 403  # Invalid auth header

    token = auth[7:]  # Remove "Bearer: " prefix

    try:
        info = id_token.verify_oauth2_token(token, reqs.Request())
        if "email" not in info:
            return "Forbidden", 403
        g.verified_email = info["email"]

        return
    except Exception as e:
        return "Forbidden", 403


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
