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

import { createSlice } from '@reduxjs/toolkit';
import { fetchCampaign, fetchCampaignList } from '../actions/campaigns.js';

export const campaignReducer = createSlice({
  name: 'campaign',
  initialState: {
    campaign: {},
    status: 'idle',
    error: null
  },
  extraReducers(builder) {
    /* eslint-disable no-param-reassign */
    builder
      .addCase(fetchCampaign.pending, (state) => {
        state.status = 'loading'
      })
      .addCase(fetchCampaign.fulfilled, (state, action) => {
        state.status = 'succeeded'
        state.campaign = action.payload
      })
      .addCase(fetchCampaign.rejected, (state, action) => {
        state.status = 'failed'
        state.error = action.error.message
      });
    /* eslint-enable no-param-reassign */
  }
}).reducer;

export const campaignListReducer = createSlice({
  name: 'campaigns',
  initialState: {
    campaigns: [],
    status: 'idle',
    error: null
  },
  extraReducers(builder) {
    /* eslint-disable no-param-reassign */
    builder
      .addCase(fetchCampaignList.pending, (state) => {
        state.status = 'loading'
      })
      .addCase(fetchCampaignList.fulfilled, (state, action) => {
        state.status = 'succeeded'
        state.campaigns = action.payload
      })
      .addCase(fetchCampaignList.rejected, (state, action) => {
        state.status = 'failed'
        state.error = action.error.message
        state.campaigns = [];
      });
    /* eslint-enable no-param-reassign */
  }
}).reducer;
