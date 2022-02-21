import { LitElement, html, css } from 'lit';
import { connect } from 'pwa-helpers/connect-mixin.js';

import '@material/mwc-top-app-bar';
import '@material/mwc-icon-button';
import CampaignCard from './campaign-card.js';
import campaignStyles from './styles/campaignList.js';
import { fetchCampaigns } from '../../stores/slices/campaigns.js';
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
    store.dispatch(fetchCampaigns());
  }

  stateChanged(state) {
    this.state = state.campaigns;
  }

  render() {
    const { status, campaigns } = this.state;

    // Notice property binding
    // https://lit.dev/docs/v1/lit-html/writing-templates/#bind-to-properties
    return html`
      <div class='campaignList'>
        ${status === 'loading' 
          ?  html`<div>loading ...</div>`
          : status === 'succeeded' 
            ? campaigns.map((d, i) => html`<campaign-card .item=${d}></campaign-card>`)
            : html`Error has occurred.`
        }
      </div>
    `;
  }
}

customElements.define('campaign-list', CampaignList);

export default CampaignList;

