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

import { css } from 'lit';

/* stylelint-disable font-family-no-missing-generic-family-keyword */
const donationPage =  css`
    .donationContainer {
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 30px auto;
      font-family: "Google Sans";
      font-weight: normal;
      width: 100%;
    }
    
    .donationWrapper {
      display: flex;
      justify-content: space-between;
      flex-wrap: wrap;
      margin: auto 30px;
      width: inherit;
      flex-direction: column;
    }
`;
/* stylelint-enable font-family-no-missing-generic-family-keyword */

export default donationPage;
