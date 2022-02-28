import { axios } from '@bundled-es-modules/axios';
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';

//TODO: Refactor out
const developmentUrl = 'http://127.0.0.1:5000/api/v1';

export const fetchCampaign = createAsyncThunk(
'posts/fetchCampaign',
  async (campaignId) => {
    console.log(campaignId);
    const response = await axios(`${developmentUrl}/get_campaign?campaign_id=${campaignId}`, { 
      method: 'GET',
      mode: 'cors',
      headers: {
        'Content-Type': 'application/json',  
        'Access-Control-Allow-Origin':'*'
      }});

    return response?.data;
  }
);

export const campaignSlice = createSlice({
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
});

export default campaignSlice.reducer;
