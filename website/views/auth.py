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


import os

from flask import Blueprint, render_template


auth_bp = Blueprint("auth", __name__, template_folder="templates")


@auth_bp.route("/login", methods=["GET"])
def login():
    oauth_client_id = os.getenv('OAUTH_CLIENT_ID');
    return render_template("auth/login.html", OAUTH_CLIENT_ID=oauth_client_id)


@auth_bp.route("/logout", methods=["GET"])
def logout():
    return render_template("auth/logout.html")
