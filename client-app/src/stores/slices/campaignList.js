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
