import { LitElement, html, css } from 'lit';
import '@material/mwc-top-app-bar';
import '@material/mwc-icon-button';

import headerStyles from './styles/header.js';

class Header extends LitElement {
  static styles = headerStyles;
  
  render() {
    return html`
      <mwc-top-app-bar>
        <div slot="title">
          <div class="titleContainer">
            <h2 class="title">Cymbal Giving</h2>
            <p class="subTitle">a Cymbal Fintech company</p>
          </div>
        </div>
        <mwc-icon-button icon="favorite" slot="actionItems"></mwc-icon-button>
      </mwc-top-app-bar>
    `;
  }
}

export default Header;
