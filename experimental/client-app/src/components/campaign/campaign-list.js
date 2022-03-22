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
import { connect } from 'pwa-helpers/connect-mixin.js';

import '@material/mwc-top-app-bar';
import '@material/mwc-icon-button';
import CampaignCard from './campaign-card.js';
import campaignStyles from './styles/campaignList.js';
import { fetchCampaignList } from '../../stores/slices/campaignList.js';
import store from '../../stores/base.js';

class CampaignList extends connect(store)(LitElement) {
  static properties = {
    state: {
      status: { type: String },
      campaigns:{ type: Array},
    }
  };
  
  static styles = campaignStyles;

  constructor() {
    super();
    this.state = { status: 'loading', campaigns: [] };
  }

  firstUpdated() {
    store.dispatch(fetchCampaignList());
  }

  stateChanged(state) {
    this.state = state.campaignList;
  }

  render() {
    const { status, campaigns } = this.state;

    let content;

    switch(status) {
      case 'succeeded': 
        content = campaigns.map((d, i) => html`<campaign-card .item=${d}></campaign-card>`);
        break;
      case 'loading': 
        content = html`<div>loading ...</div>`;
        break;
      default: 
        content = html`Error has occurred.`;
    }

    // Notice property binding
    // https://lit.dev/docs/v1/lit-html/writing-templates/#bind-to-properties
    return html`
      <div class='campaignList'>
        ${content} 
      </div>
    `;
  }
}

customElements.define('campaign-list', CampaignList);

export default CampaignList;

