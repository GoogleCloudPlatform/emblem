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

import json
import pytest

import main
from resources import methods


kinds = [key for key in methods.resource_fields]


@pytest.fixture
def client():
    main.app.testing = True
    return main.app.test_client()


def test_list(client):
    for kind in kinds:
        r = client.get("/{}".format(kind))
        assert r.status_code == 200
        assert r.headers.get("Content-Type") == "application/json"
        payload = json.loads(r.data)
        assert type(payload) == list
