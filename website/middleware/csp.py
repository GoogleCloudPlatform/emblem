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
import secrets

import emblem_client


def init(app):
    @app.before_request
    def set_csp_nonce():
        g.csp_nonce = secrets.token_urlsafe(32)

    @app.after_request
    def set_csp_policy(response):
        image_origins = "*"

        font_origins = " ".join(["fonts.gstatic.com", "fonts.googleapis.com"])

        policy = "; ".join(
            [
                f"img-src {image_origins}",
                f"font-src {font_origins}",
                f"script-src 'nonce-{g.csp_nonce}'",
                # Static fields requested by Lighthouse CI
                "object-src 'none'",
                "base-uri 'self'",
            ]
        )

        response.headers["Content-Security-Policy"] = policy
        return response
