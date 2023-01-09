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

import { LitElement, html } from 'lit';
import { connect } from 'pwa-helpers/connect-mixin.js';
import { getCampaignItem } from '../../selectors/campaigns.js';
import { fetchCampaign } from '../../actions/campaigns.js';
import store from '../../stores/base.js';
import campaignStyles from './styles/campaignPage.js';

const websiteIcon = new URL('../../../assets/website-icon.png', import.meta.url).href;
const infoIcon = new URL('../../../assets/info-icon.png', import.meta.url).href;

import '@material/mwc-tab-bar';
import '@material/mwc-tab';

class CampaignPage extends connect(store)(LitElement) {
  static styles = campaignStyles;

  constructor() {
    super();
    this.campaign = {};
  }
  
  firstUpdated() {
    const campaignId = location.pathname.split('/campaigns/')[1];
    store.dispatch(fetchCampaign(campaignId));
  }

  stateChanged(state) {
    this.campaign = state.campaign;
    this.requestUpdate();
  }

  render() {
    const { status, campaign } = this.campaign;
    const { donations } = campaign;
  
    return html`
      <div class="campaignContainer">
        ${campaign.id ? (
          html`<div class="campaignWrapper">
            <!------ left panel ----->
            <div class="leftPanel">
              <h1 class="title">${campaign.name}</h1>
              <h3 class="description">
                ${campaign.description}
              </h3>
              <div class="about">
                <div class="circle">
                  <img class="infoIcon" src=${infoIcon}></img>
                </div>
                <div>
                  <div class="aboutTitle">About this cause</div>
                  <p>${campaign.description}</p>
                </div>
              </div>
              ${campaign.url && html`
                <div class="website">
                  <div class="circle">
                    <img class="websiteIcon" src=${websiteIcon}></img>
                  </div>
                  <div>
                    <div class="websiteTitle">Website</div>
                    <a href=${campaign.url}>${campaign.url}</a>
                  </div>
                </div>
              `}
              <div class="donationHistory">
                <h4 class="title">Donation history</h4>
                <div class="donationTableWrapper">
                  <table class="donationTable">
                    <tr class="tableHeader">
                      <th>Name</th>
                      <th>Amount</th>
                      <th>Date</th>
                    </tr>
                    ${donations && donations.length 
                      ? donations.map((d, i) => html`
                          <tr>
                            <td>${d.donor}</td>
                            <td>${d.amount}</td>
                            <td>${d.timeCreated}</td>
                          </tr>
                        `) 
                        : html`<tr><td>No donations yet.</td></tr>`}
                  </table>
                </div>
              </div>
            </div>
            <!------ right panel ----->
            <div class="rightPanel">
              <mwc-tab-bar>
                <mwc-tab label="CURRENT CAMPAIGNS"></mwc-tab>
              </mwc-tab-bar>
              <div class="tabBody"></div>
            </div>
          </div>`
        ): html`<div>loading...</div>`}
      </div>
    `;
  }
}

customElements.define('campaign-page', CampaignPage);

export default CampaignPage;

