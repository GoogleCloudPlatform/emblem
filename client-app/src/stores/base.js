import { configureStore } from '@reduxjs/toolkit';
import campaignReducer from './slices/campaign.js';
import campaignListReducer from './slices/campaignList.js';

export default configureStore({
  reducer: {
    campaign: campaignReducer,
    campaignList: campaignListReducer
  }
});
