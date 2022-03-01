import { axios } from '@bundled-es-modules/axios';
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';

//TODO: Refactor out into another file
const developmentUrl = 'http://127.0.0.1:5000/api/v1';

export const fetchCampaignList = createAsyncThunk(
'posts/fetchCampaignList',
  async () => {
    const response = await axios(`${developmentUrl}/campaigns`, { 
      method: 'GET',
      mode: 'cors',
      headers: {
        'Content-Type': 'application/json',  
        'Access-Control-Allow-Origin':'*'
      }});

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
