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

export const { CLIENT_ID } = process.env;
export const { CLIENT_SECRET } = process.env;
export const { REDIRECT_URI } = process.env;
export const { SITE_URL } = process.env;
export const JWT_SECRET = process.env.JWT_SECRET || 'test_default_secret';
export const COOKIE_NAME = 'auth_token';
