import { LitElement, html } from 'lit';
import { connect } from 'pwa-helpers/connect-mixin.js';
import { getCampaignItem } from '../../stores/selectors/campaigns.js';
import { fetchCampaign } from '../../stores/slices/campaign.js';
import store from '../../stores/base.js';
import campaignStyles from './styles/campaignPage.js';
import '@material/mwc-tab-bar';
import '@material/mwc-tab';

class CampaignPage extends connect(store)(LitElement) {
  static properties = {
    campaign: { name: { type: String }},
  };
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
                <div class="circle"></div>
                <div>
                  <h5>About this cause</h5>
                  <p>${campaign.description}</p>
                </div>
              </div>
              <div class="website">
                <div class="circle"></div>
                <div>
                  <h5>Website</h5>
                  <a href="http://google.com">http://google.com</a>
                </div>
              </div>
              <div class="donationHistory">
                <h4>Donation history</h4>
                <table class="donationTable">
                  <tr class="tableHeader">
                    <th>Name</th>
                    <th>Amount</th>
                    <th>Date</th>
                  </tr>
                  ${donations.length 
                    ? donations.map((d, i) => html`
                        <tr>
                          <td>Jane Doe</td>
                          <td>100.00</td>
                          <td>1/30/2022</td>
                        </tr>
                      `) 
                      : html`<tr><td>No donations yet.</td></tr>`}
                </table>
              </div>
            </div>
            <!------ right panel ----->
            <div class="rightPanel">
              <mwc-tab-bar>
                <mwc-tab label="CURRENT CAMPAIGNS"></mwc-tab>
                <mwc-tab label="UPCOMING CAMPAIGNS"></mwc-tab>
                <mwc-tab label="PAST CAMPAIGNS"></mwc-tab>
              </mwc-tab-bar>
              <div class="tabBody"></div>
            </div>
          </div>`
        ): 'Loading'}
      </div>
    `;
  }
}

customElements.define('campaign-page', CampaignPage);

export default CampaignPage;

