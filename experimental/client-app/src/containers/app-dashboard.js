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

import { LitElement, html } from 'lit';
import { connect } from 'pwa-helpers/connect-mixin.js';
import shellStyles from '../styles/shell.js';
import CampaignList from '../components/campaign/campaign-list.js';
import { fetchCampaignList } from '../actions/campaigns.js';
import store from '../stores/base.js';

class Dashboard extends connect(store)(LitElement) {
  static styles = shellStyles;

  constructor() {
    super();
    this.state = { status: 'loading', campaigns: [] };
  }
  
  firstUpdated() {
    store.dispatch(fetchCampaignList());
  }

  // Note: https://lit.dev/docs/components/lifecycle/#reactive-update-cycle
  stateChanged(state) {
    this.state = state.campaignList;
    this.requestUpdate();
  }

  render() {
    const { status, campaigns } = this.state;
    let content;

    switch(status) {
      case 'succeeded': 
        content = html`<campaign-list .campaigns=${campaigns}></campaign-list>`;
        break;
      case 'loading': 
        content = html`<div>loading ...</div>`;
        break;
      default: 
        content = html`Error has occurred.`;
    }
    
    return html`
      <div class="title">
        Discover a cause or a campaign
      </div>
      <div class="dashboardWrapper">${content}</div>
    `;
  }
}

customElements.define('app-dashboard', Dashboard);

export default Dashboard;
