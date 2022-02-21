
import { configureStore } from '@reduxjs/toolkit';

import campaignReducer from './slices/campaigns.js';

export default configureStore({
  reducer: {
    campaigns: campaignReducer
  }
});
