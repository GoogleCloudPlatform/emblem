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

/* stylelint-disable font-family-no-missing-generic-family-keyword */
const campaignPage =  css`
    .leftPanel,
    .rightPanel {
      width: inherit;
      max-width: 48%;
    }

    .title {
      font-size: 36px;
      font-weight: normal;
    }

    .about, 
    .website {
      font-weight: 400;
      font-size: 16px;
      display: flex;
      align-items: center;
      margin: 10px 0;
      border-bottom: 1px solid light-grey;
    }
    
    .circle {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 50px;
      height: 50px;
      min-width: 50px;
      margin-right: 20px;
      background: linear-gradient(332.1deg, #86F7B1 14.81%, #2C67FF 62.34%);
      border-radius: 50px;
    }

    .campaignContainer {
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 30px auto;
      font-family: "Google Sans";
      font-weight: normal;
      width: 100%;
    }
    
    .campaignWrapper {
      display: flex;
      justify-content: space-between;
      flex-wrap: wrap;
      margin: auto 30px;
      width: inherit;
    }

    .donationHistory {
      width: 100%;
    }

    .donationTableWrapper {
      border: 1px solid lightgray;
      border-radius: 5px;
      margin: 10px 0;
      overflow: hidden;
    }

    table.donationTable {
      width: 100%;
      text-align: left;
      border-collapse: collapse;
    }

    table.donationTable .tableHeader {
      background-color: #F5F5F5;
      padding: 10px;
    }
    
    table.donationTable tr {
      display: flex;
      justify-content: space-around;
      padding: 10px;
    }
    
    table.donationTable tr:not(:last-child) {
      border-bottom: 1px solid lightgray;
    }
`;
/* stylelint-enable font-family-no-missing-generic-family-keyword */

export default campaignPage;
