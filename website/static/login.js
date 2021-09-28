// Copyright 2021 Google LLC
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


// Emblem uses GCP's Cloud Identity Platform product to handle end-user
// authentication. This product is built atop Firebase Authentication, which
// itself is designed primarily for client-side applications (such as mobile
// or "single-page" [SPA] apps). Thus, we manage authentication on the *client*
// even though Emblem itself is a *server-side* (Python + Flask) app.


// Save Firebase Auth ID token in a cookie on every page refresh
// (This is necessary in case the ID token expires)
const refreshToken = async function () {
    firebase.auth().onAuthStateChanged(async (user) => {
        if (user) {
            const token = await user.getIdToken();
            Cookies.set("session", token, { secure: true });
        }
    });
}


// Authenticate user
const loginUser = async function () {
    firebase.auth().setPersistence(firebase.auth.Auth.Persistence.NONE)
    const authProvider = new firebase.auth.GoogleAuthProvider();
    const {user} = await firebase.auth().signInWithPopup(authProvider);

    // Redirect to homepage
    window.location.href = '/';
};


// Log out user
const logoutUser = async function () {
    firebase.auth().signOut();

    // Remove session cookie
    Cookies.remove("session");

    // Redirect to homepage
    window.location.href = '/';
}


window.onload = function () {
    const path = window.location.pathname;

    // If on login page, authenticate the current user
    if (path == '/login') {
        loginUser();
    }

    // If on logout page, sign current user out
    if (path == '/logout') {
        logoutUser();
    }

    refreshToken();
}



