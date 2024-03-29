// Copyright 2023 Google LLC
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

import { createAsyncThunk } from '@reduxjs/toolkit';
import { getConfig } from '../utils/config.js';

const developmentUrl = getConfig().API_URL;

export const fetchCampaign = createAsyncThunk(
  'fetchCampaign',
  async campaignId => {
    let campaign = {};
    let donations = [];

    const headers = {
      method: 'GET',
      headers: { 
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      }
    };

    try {
      // Fetch campaign
      const campaignResponse = await fetch(`${developmentUrl}/campaigns/${campaignId}`, headers);
      campaign = await campaignResponse.json();
      // Fetch campaign donations
      const donationResponse = await fetch(`${developmentUrl}/campaigns/${campaignId}/donations`, headers);
      donations = await donationResponse.json();
      campaign['donations'] = donations || [];
    } catch (e) {
      console.error(e);
    }

    return campaign;
  }
);

export const fetchCampaignList = createAsyncThunk(
  'fetchCampaignList',
  async () => {
    let campaigns;
    try {
      const response = await fetch(`${developmentUrl}/campaigns`,
      {
        method: 'GET',
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        }
      });
      campaigns = await response.json();
    } catch (e) {
      console.error(e);
    }

    return campaigns;
  }
);
