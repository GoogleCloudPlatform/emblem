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

from flask import Flask, current_app

from views.campaigns import campaigns_bp
from views.donations import donations_bp
from views.errors import errors_bp
from views.auth import auth_bp
from views.robots_txt import robots_txt_bp

from middleware import auth, csp

app = Flask(__name__)

app.register_blueprint(errors_bp)
app.register_blueprint(donations_bp)
app.register_blueprint(campaigns_bp)
app.register_blueprint(auth_bp)
app.register_blueprint(robots_txt_bp)

# Initialize middleware
auth.init(app)
csp.init(app)


if os.path.exists("config.py"):
    app.config.from_object("config")
else:
    raise Exception("Missing configuration file.")


if __name__ == "__main__":
    PORT = int(os.getenv("PORT")) if os.getenv("PORT") else 8080

    # This is used when running locally. Gunicorn is used to run the
    # application on Cloud Run; see "entrypoint" parameter in the Dockerfile.
    app.run(host="127.0.0.1", port=PORT, debug=True)
