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

from middleware.logging import log

import pytz

def convert_utc(time):
  pacific_zone = pytz.timezone('America/Los_Angeles')

  if time is not None:
    converted_time = time.astimezone(pacific_zone)
  else:
    log(f"Exception while converting timestamp: No datetime given", severity="ERROR")
    return time

  return converted_time.strftime('%m/%d/%y (%I:%M %p %Z)')