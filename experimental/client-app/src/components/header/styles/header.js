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

import { css } from 'lit';

const headerStyles =  css`
      .cloudLogo {
        height: 20px;
      }

      .cymbalGivingLogo {
        height: 90px;
      }

      .headerContainer {
        display: flex;
        align-items: center;
        justify-content: space-between;
        color: #606367;
      }

      .headerWrapper {
        display: flex;
        align-items: center;
      }
      
      .headerWrapper .login,
      .headerWrapper .logout {
        color: gray;
      }

      .cloudLogoWrapper {
        display: flex;
        flex-direction: column;
      }
      
      .cloudLogoWrapper p {
        margin: 5px 0;
        font-size: 18px;
      }

      .banner {
        background-color: #306DFD;
        padding: 25px;
        color: white;
        font-size: 16px;
        line-height: 24px;
        display: flex;
        align-items: center;
        justify-content: center;
        text-align: center;
        box-shadow: 0 0 8px #ccc;
        margin-bottom: 10px;
      }
    `;

export default headerStyles;

