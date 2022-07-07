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

import { getConfig } from './config.js';

/**
 * /login - directs user to Google sign-in page
 * For more information, see https://developers.google.com/identity/protocols/oauth2/web-server
 */ 
export const login = () => {
    const { SITE_URL, REDIRECT_URI, AUTH_CLIENT_ID } = getConfig();
    
    // Link to redirect to Google auth service, including required query parameters.
    let signInUrl = 'https://accounts.google.com/o/oauth2/v2/auth?';
    // Client apps and their callbacks must be registered and supplied here
    signInUrl += `redirect_uri=${REDIRECT_URI}&`;
    signInUrl += `client_id=${AUTH_CLIENT_ID}&`;
    // Asking for user email and any previously granted scopes
    signInUrl += `scope=openid%20email&`
    signInUrl += `include_granted_scopes=true&`
    // The next two parameters are essential to get a refresh token
    signInUrl += `prompt=consent&`
    signInUrl += `access_type=offline&`
    // Asking for a code that can then be exchanged for user information
    signInUrl += `response_type=code&`
    signInUrl += `state=${SITE_URL}&`;

    location.href = signInUrl;
};

/**
 * /logout - deletes the user login session and revokes refresh token
 * For more information, see https://developers.google.com/identity/protocols/oauth2/web-server
 */ 
export const logout = async () => {
    const { API_URL } = getConfig();

    await fetch(`${API_URL}/logout`, { method: 'GET' });
};

export default { login, logout };
