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

from flask import g, render_template

from middleware.logging import log

from views.helpers.time import convert_utc

from functools import reduce


def get_donor_name(donation):
    if donation is None:
        log(
            f"Exception while retrieving donor name: No donation given",
            severity="ERROR",
        )
        return ""

    try:
        donor = g.api.donors_id_get(donation["donor"])
        if donor is not None:
            donation["donorName"] = donor["name"]
            donation["formattedDateCreated"] = convert_utc(donation.time_created)
    except Exception as e:
        log(f"Exception while retrieving donor name: {e}", severity="ERROR")
        return render_template("errors/403.html"), 403

    return donation
