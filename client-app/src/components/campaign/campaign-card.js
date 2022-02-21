import { LitElement, html, css } from 'lit';
import campaignStyles from './styles/campaignCard.js';


class CampaignCard extends LitElement {
  static properties = {
    item: {type: Object},
  };
  static styles = campaignStyles;
  
  constructor() {
    super();
    this.item = {};
  }
  
  render() {
    const path = `/campaigns/${this.item.id}`; 
    
      return html`<div class="card">
      ${this.item && html`
      <div style="background-image:url(${this.item.image_url}); background-size: cover; height: 100px;"></div>
        <div class="cardWrapper">
          <div class="cardContent">
            <p class="cardName">${this.item.name}<p>
            <p>${this.item.description}</p>
          </div>
          <div class="actionWrapper">
            <a class="fillButton" href="/donate">Donate</a>
            <a class="button" href=${path}>Learn more</a>
          </div>
        </div>
      </div>`}
    </div>`;
  }
}

customElements.define('campaign-card', CampaignCard);

export default CampaignCard;
