import { LitElement, html, css } from 'lit';
import '@material/mwc-top-app-bar';
import '@material/mwc-icon-button';

import headerStyles from './styles/header.js';

const cloudLogo = new URL('../../../assets/google-cloud-logo.png', import.meta.url).href;
const cymbalGivingLogo = new URL('../../../assets/cymbal-giving-logo.png', import.meta.url).href;

class Header extends LitElement {
  static styles = headerStyles;

  render() {
    return html`
      <div class="headerContainer">
        <img class="cymbalGivingLogo" src=${cymbalGivingLogo}></img>
        <div class="headerWrapper">
          <div class="cloudLogoWrapper">
            <p>Powered by</p>
            <img class="cloudLogo" src=${cloudLogo}></img>
          </div>
          <mwc-icon-button icon="help_outline" slot="actionItems"></mwc-icon-button>
          <mwc-icon-button icon="notifications" slot="actionItems"></mwc-icon-button>
          <mwc-icon-button icon="account_circle" slot="actionItems"></mwc-icon-button>
          <mwc-icon-button icon="login" slot="actionItems"></mwc-icon-button>
        </div>
      </div>
      <div class="banner">
        This website is hosted for demo purposes only. No money will be moved by exploring these features. This is not a Google product. © 2021 Google Inc
      </div>
    `;
  }
}

customElements.define('app-header', Header);

export default Header;
