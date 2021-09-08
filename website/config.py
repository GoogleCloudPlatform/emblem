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


####################################################
# TODO(developer): set these environment variables #
####################################################


# The (public!) API key used by Firebase.
# This should be of the format "AIza..."
FIREBASE_API_KEY = os.getenv("EMBLEM_FIREBASE_API_KEY")

# The domain name used by Firebase Auth
FIREBASE_AUTH_DOMAIN = os.getenv("EMBLEM_FIREBASE_AUTH_DOMAIN")
