# Copyright 2022 Google, LLC.
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

##############################################################
# This Dockerfile creates an image that is used to run tests #
##############################################################

FROM google/cloud-sdk:alpine

# Install pip
RUN apk add py3-pip

# Install Terraform
RUN apk add terraform --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community

# Install packages used by Content API
RUN pip install -r content-api-requirements.txt
