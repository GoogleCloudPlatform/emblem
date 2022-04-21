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

import { LitElement, html, css } from 'lit';
import '@material/mwc-top-app-bar';
import '@material/mwc-icon-button';
import CampaignCard from './campaign-card.js';
import campaignStyles from './styles/campaignList.js';

class CampaignList extends LitElement {
  static properties = {
    campaigns:{ type: Array},
  };
  
  static styles = campaignStyles;

  constructor() {
    super();
    this.campaigns = [];
  }

  render() {
    // Notice property binding
    // https://lit.dev/docs/v1/lit-html/writing-templates/#bind-to-properties
    return html`
      <div class='campaignList'>
        ${this.campaigns.map((d, i) => html`<campaign-card .item=${d}></campaign-card>`)}
      </div>
    `;
  }
}

customElements.define('campaign-list', CampaignList);

export default CampaignList;

