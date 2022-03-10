import { axios } from '@bundled-es-modules/axios';
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';

const developmentUrl = 'http://localhost:3000';

export const fetchCampaign = createAsyncThunk(
'posts/fetchCampaign',
  async (campaignId) => {
    let response;

    try {
      response = await axios.get(`${developmentUrl}/campaigns/${campaignId}`, {
        headers: {
          'Content-Type': 'application/json',
          'Authorization':'your_key'
        },
      });
    } catch(e) {
      console.log(e);
    }


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
