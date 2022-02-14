import { LitElement, html, css } from 'lit';

import '@material/mwc-top-app-bar';
import '@material/mwc-icon-button';

import campaignStyles from './styles/campaignList.js';
import data from './dummy/data.js';

class CampaignList extends LitElement {
  static properties = {
    data: {type: Array},
  };
  
  static styles = campaignStyles;

  constructor() {
    super();
    this.data = data;
  }

  render() {
    return html`
      <div class='campaignList'>
        ${this.data?.map((d, i) => html`<div class="card">
          <div style="background-image:url(${d.image_url}); background-size: cover; height: 100px;"></div>
          <p class="cardName">${d.name}<p>
          <p>${d.description}</p>
        </div>`)}
      </div>
    `;
  }
}

export default CampaignList;
