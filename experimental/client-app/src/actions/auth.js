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

import { createAsyncThunk } from '@reduxjs/toolkit';
import { getConfig } from '../utils/config.js';

const developmentUrl = getConfig().REDIRECT_URL.replace('/callback', '');

/**
 * logout - deletes the user login session and revokes refresh token
  // TODO: Remove session id/data from cookie if exists
 * For more information, see https://developers.google.com/identity/protocols/oauth2/web-server
 */ 
export const fetchLoggedIn = createAsyncThunk('fetchLoggedIn', async () => {
  let loggedIn;
  const url = `${developmentUrl}/loggedIn`;
  
  try {
    const response = await fetch(url);
    loggedIn = await response.json();
  
    debugger
  } catch(e) {
    console.error(e);
  }
  return loggedIn;
});
