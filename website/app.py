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

import datetime

from flask import Flask, render_template

app = Flask(__name__)

# TODO(anassri, engelke): use API call instead of this
# (This is based on the API design doc for now.)

SAMPLE_CAMPAIGNS = [
    {
        'name': 'cash for camels',
        'goal': 2500,
        'managers': [
            'Chris the camel',
            'Carissa the camel'
        ],
        'updated': datetime.date(2021, 2, 1)
    },
    {
        'name': 'water for fish',
        'goal': 2500,
        'managers': [
            'Fred the fish',
        ],
        'updated': datetime.date(2021, 5, 10)
    }
]


@app.route('/')
def listCampaigns():
    return render_template(
        'home.html',
        campaigns=SAMPLE_CAMPAIGNS
    )
