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

import { createSlice } from '@reduxjs/toolkit';
import { fetchSession } from '../actions/auth.js';

export const sessionReducer = createSlice({
  name: 'session',
  initialState: {
    hasSession: false,
    status: 'idle',
    error: null
  },
  extraReducers(builder) {
    /* eslint-disable no-param-reassign */
    builder
      .addCase(fetchSession.pending, (state) => {
        state.status = 'loading'
      })
      .addCase(fetchSession.fulfilled, (state, action) => {
        state.status = 'succeeded'
        state.hasSession = action.payload
      })
      .addCase(fetchSession.rejected, (state, action) => {
        state.status = 'failed'
        state.error = action.error.message
      });
    /* eslint-enable no-param-reassign */
  }
}).reducer;
