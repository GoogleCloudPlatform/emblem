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

import os

from middleware.logging import log

import generated
from generated.api_client import ApiClient
from generated.api.default_api import DefaultApi
from generated.configuration import Configuration


class EmblemClient(object):
    """API client for Emblem

    :host: Required. URI of API server
    :param access_token: required when making authentication calls
    """

    def __init__(self, host, access_token=None, trace=None):
        if host is None:
            log(f"Asked to create an EmblemClient for no host", severity="ERROR")
            raise ValueError
            
        conf = Configuration(host=host)

        if access_token is not None:
            api_client=ApiClient(
                configuration=conf,
                header_name="Authorization",
                header_value="Bearer " + access_token,
            )
        else:
            api_client=ApiClient(configuration=conf)

        if trace is not None:
            api_client.default_header["Forwarded-Trace-Context"] = trace

        client = DefaultApi(api_client=api_client)

        for method in client.__dict__:
            self.__dict__[method] = client.__dict__[method]

        return None
