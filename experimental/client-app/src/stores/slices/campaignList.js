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

import { axios } from '@bundled-es-modules/axios';
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';

const developmentUrl = 'http://localhost:3000';

export const fetchCampaignList = createAsyncThunk(
'posts/fetchCampaignList',
  async () => {
    let response;

    try {
      response = await axios.get(`${developmentUrl}/campaigns`, {
        headers: {
          'Content-Type': 'application/json',
          'Authorization':'your_key'
        }
      });
    } catch(e) {
      console.log(e);
    }

    return response?.data;
  }
);

export const campaignListSlice = createSlice({
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
});

export default campaignListSlice.reducer;
