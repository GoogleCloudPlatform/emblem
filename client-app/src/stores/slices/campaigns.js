import { axios } from '@bundled-es-modules/axios';
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';

export const fetchCampaigns = createAsyncThunk('posts/fetchCampaigns', async () => {
  const response = await axios('http://127.0.0.1:5000/api/v1/campaigns', { 
    method: 'GET',
    mode: 'cors',
    headers: {
      'Content-Type': 'application/json',  
      'Access-Control-Allow-Origin':'*'
    }});

  return response?.data
})

export const campaignSlice = createSlice({
  name: 'campaigns',
  initialState: {
    campaigns: [],
    status: 'idle',
    error: null
  },
  extraReducers(builder) {
    /* eslint-disable no-param-reassign */
    builder
      .addCase(fetchCampaigns.pending, (state) => {
        state.status = 'loading'
      })
      .addCase(fetchCampaigns.fulfilled, (state, action) => {
        state.status = 'succeeded'
        state.campaigns = action.payload
      })
      .addCase(fetchCampaigns.rejected, (state, action) => {
        state.status = 'failed'
        state.error = action.error.message
      });
    /* eslint-enable no-param-reassign */
  }
});

export default campaignSlice.reducer;
