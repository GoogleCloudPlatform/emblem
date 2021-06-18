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


from flask import Blueprint, render_template


errors_bp = Blueprint("errors", __name__, template_folder="templates")


@errors_bp.app_errorhandler(401)
def error_no_auth_credential(err):
    return render_template("errors/401.html")


@errors_bp.app_errorhandler(403)
def error_access_denied(err):
    return render_template("errors/403.html")


@errors_bp.app_errorhandler(404)
def error_not_found(err):
    return render_template("errors/404.html")


@errors_bp.app_errorhandler(500)
def error_internal(err):
    return render_template("errors/500.html")
