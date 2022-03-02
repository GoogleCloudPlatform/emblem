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
        <div class="cardImage" style="background-image:url(${this.item.image_url}); background-color: lightgray; background-size: cover; height: 150px;"></div>
        <div class="cardWrapper">
          <div class="cardContent">
            <div class="title">${this.item.name}</div>
            <div class="description">${this.item.description}</div>
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
