import { LitElement, html } from 'lit';
import '@material/mwc-button';
import '@material/mwc-top-app-bar';
import shellStyles from './styles/shell.js';
import Dashboard from './app-dashboard.js';
//import CampaignPage from './containers/campaign/campaign-page.js';
import Header from './components/header/header.js';
import { initRouter } from './utils/router.js';

class AppShell extends LitElement {
  static properties = {
    title: { type: String },
  };
  
  static styles = shellStyles;

  constructor() {
    super();
    this.title = 'Cymbal Giving';
  }

  firstUpdated() {
    initRouter();
  }

  render() {
    return html`
      <app-header></app-header>
    `;
  }
}

customElements.define('app-shell', AppShell);

export default AppShell;

