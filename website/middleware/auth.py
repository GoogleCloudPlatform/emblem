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

from flask import g, request

import emblem_client

import os


def init(app):
    @app.before_request
    def check_user_authentication():
        id_token = request.cookies.get("session", None)

        g.api = emblem_client.EmblemClient(
            app.config.get("EMBLEM_API_URL", None), access_token=id_token
        )
