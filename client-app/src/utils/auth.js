// Copyright 2023 Google LLC
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
    const { REDIRECT_URI, AUTH_CLIENT_ID } = getConfig();

    const rootUrl = 'https://accounts.google.com/o/oauth2/v2/auth';
    const options = new URLSearchParams({
        redirect_uri: REDIRECT_URI,
        client_id: AUTH_CLIENT_ID,
        access_type: 'offline',
        response_type: 'code',
        prompt: 'consent',
        scope: [
            'https://www.googleapis.com/auth/userinfo.profile',
            'https://www.googleapis.com/auth/userinfo.email',
        ].join(' '),
    });

    location.href = `${rootUrl}?${options.toString()}`;
};

/**
 * /hasCookie - checks if user is logged in
 */ 
export const hasCookie = async () => {
    const { AUTH_API_URL } = getConfig();
    let retrievedCookie = false;

    try {
        retrievedCookie = await fetch(`${AUTH_API_URL}/hasCookie`);
    } catch(e) {
        throw new Error(e);
    }

    return retrievedCookie;
};

/**
 * /logout - deletes the user login session and revokes refresh token
 * For more information, see https://developers.google.com/identity/protocols/oauth2/web-server
 */ 
export const logout = async () => {
    const { AUTH_API_URL } = getConfig();

    try {
        await fetch(`${AUTH_API_URL}/logout`);
    } catch(e) {
        throw new Error(e);
    }
};

export default { login, logout, hasCookie };
