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
    const { REDIRECT_URI, AUTH_CLIENT_ID } = getConfig();

    const returnTo = '/';
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
    signInUrl += `state=${returnTo}&`;

    location.href = signInUrl;
};

/**
 * /callback - successful login to Google sign-in page causes a redirect
 * here. This handler fetches user information and establishes a session
 * with that information
 * For more information, see https://developers.google.com/identity/protocols/oauth2/web-server
 */ 
export const callback = async(params) => {
    const redirectPath = params['state'];
    const code = params['code'];

    if(!code) {
        //log("No authorization code provided to callback.", severity="CRITICAL")
        //return render_template("errors/403.html"), 403
        return;
    }

    const data= {
        "code": code,
        "client_id": current_app.config["CLIENT_ID"],
        "client_secret": current_app.config["CLIENT_SECRET"],
        "redirect_uri": current_app.config["REDIRECT_URI"],
        "grant_type": "authorization_code",
    };

    const response = await fetch('https://oauth2.googleapis.com/token', { method: 'POST', body: data });
    const token = response['id_token'];
    const refresh_token = response['refresh_token'];

    /*
    //info = id_token.verify_oauth2_token(token, reqs.Request())
    session_id = session.create(
        {
            "id_token": token,
            "refresh_token": refresh_token,
            "email": info["email"],
            "expiration": info["exp"],
        }
    )

    response.set_cookie("session_id", value=session_id, secure=True, httponly=True)
    */
}

/**
 * /logout - deletes the user login session and revokes refresh token
 * For more information, see https://developers.google.com/identity/protocols/oauth2/web-server
 */ 
export const logout = () => {
  // TODO: Remove session id/data from cookie if exists
};

export default { login, callback, logout };
