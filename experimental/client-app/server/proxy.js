// Copyright 2022 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

const express = require('express');
const morgan = require('morgan');
const cors = require('cors');
const { createProxyMiddleware } = require('http-proxy-middleware');

// Creating express server
const app = express();

const PORT = 3000;
const HOST = 'localhost';
// TODO: Remove hardcode & make dynamic
const API_SERVICE_URL = 'https://api-pwrmtjf4hq-uc.a.run.app';

// Logging
app.use(morgan('dev'));
app.use(cors());

app.use(
  '/campaigns',
  createProxyMiddleware({
    target: API_SERVICE_URL,
    headers: {
      accept: 'application/json',
      method: 'GET',
    },
    changeOrigin: true,
  })
);

app.use(
  '/viewCampaign?campaign_id=:campaignId',
  createProxyMiddleware({
    target: API_SERVICE_URL,
    headers: {
      accept: 'application/json',
      method: 'GET',
    },
    changeOrigin: true,
  })
);

// Start proxy
app.listen(PORT, HOST, () => {
  /* eslint-disable-next-line no-console */
  console.log(`Starting Proxy at ${HOST}:${PORT}`);
});
