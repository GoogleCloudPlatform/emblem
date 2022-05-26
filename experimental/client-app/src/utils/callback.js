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
 * Helper function to create cookie
 */ 
export default setCookie(name, value, exp) {
    let date = new Date();
    date.setTime(date.getTime() + (expDays * 24 * 60 * 60 * 1000));

    const expires = "expires=" + date.toUTCString();
    document.cookie = name + "=" + value + "; " + expires + "; path=/";
}

/**
 * /callback - successful login to Google sign-in page causes a redirect
 * here. This handler fetches user information and establishes a session
 * with that information
 * For more information, see https://developers.google.com/identity/protocols/oauth2/web-server
 */ 
export const callback = async(params) => {
    // TODO: Clean this up at a later time
    const state = params[0].split('=')[1];
    const code = params[1].split('=')[1];

    if (!code) {
        // TODO: Return error that no auth code has been provided in query params
        location.href = '/';
    }

    const { REDIRECT_URI, AUTH_CLIENT_ID, AUTH_CLIENT_SECRET } = getConfig();
    const data = `code=${code}&client_id=${AUTH_CLIENT_ID}&client_secret=${AUTH_CLIENT_SECRET}&redirect_uri=${REDIRECT_URI}&grant_type=authorization_code`;

    const response = await fetch(
        'https://oauth2.googleapis.com/token', {
            method: 'POST',
            body: data
        }
    );
  
    // On successful refresh token creation
    // create session cookie
    if (response.status === 200) {
        let token = response?.['id_token'];
        let refresh_token = response?.['refresh_token'];

        // TODO: This needs to be a server side session object
        // Do not store this in the browser
        setCookie('session_id', {
            "id_token": token,
            "refresh_token": refresh_token,
            "expiration": 30
        }, 30);
    } else {
        // TODO: Return error that user hasn't been signed in
        location.href = '/';
    }
}

export default callback;
