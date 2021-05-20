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

from flask import Flask, request

from resources import approvers


app = Flask(__name__)



@app.route('/approvers/', defaults={'approver': None}, methods=['GET', 'POST'])
@app.route('/approvers/<string:approver>', methods=['GET', 'PUT', 'DELETE', 'PATCH'])
def handle_approvers(approver):
    if approver is None:
        if request.method == 'GET':
            return approvers.list()

        elif request.method == 'POST':
            if not request.is_json:
                return 'Unsupported media type', 415

            body = request.get_json(silent=True)
            if body is None:
                return 'Bad request', 400

            return approvers.insert(body)
        else:
            return 'Method not allowed', 405

    else:
        if request.method == 'GET':
            return approvers.get(approver)
        elif request.method == 'DELETE':
            return approvers.delete(approver)
        elif request.method == 'PATCH':
            if not request.is_json:
                return 'Unsupported media type', 415

            body = request.get_json(silent=True)
            if body is None:
                return 'Bad request', 400

            return approvers.patch(approver, body)
        else:
            return 'Method not allowed', 405


if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080, debug=True)