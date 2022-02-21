import { LitElement, html } from 'lit';
import { getCampaignItem } from '../../stores/selectors/campaigns.js';
import store from '../../stores/base.js';

class CampaignPage extends LitElement {
  static properties = {
    campaign: { name: { type: String }},
  };

  constructor() {
    super();
    this.campaign = {};
  }

  firstUpdated() {
    const campaignId = location.pathname.split('/campaigns/')[1];
    this.campaign = getCampaignItem(store, campaignId);
  }

  render() {
    return html`
      <div class="campaign-container">
        ${this.campaign.id ? html`<div>${this.campaign.name}</div>`: 'Loading'}
      </div>
    `;
  }
}

customElements.define('campaign-page', CampaignPage);

export default CampaignPage;

