# Copyright 2021 Google, LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

###################################################################
# This Dockerfile is used to run the website for Playwright tests #
###################################################################

FROM mcr.microsoft.com/playwright:v1.29.1-focal-amd64
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && \
    apt-get install -y python3.10 python3-setuptools python3-pip

# NOTE: Playwright NPM packages ***CAN NOT*** be installed here,
# and must be installed within Cloud Build itself. This is because:
# 1) Those packages are listed in `package.json`
# 2) Thus, `npm` insists that they are installed locally.
# 3) Cloud Build overwrites local packages upon `git clone`-ing.

# Alias "python" to "python3"
RUN ln -s /usr/bin/python3 /usr/bin/python
