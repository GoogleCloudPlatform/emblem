import { LitElement, html } from 'lit';
import { connect } from 'pwa-helpers/connect-mixin.js';

import '@material/mwc-button';
import '@material/mwc-top-app-bar';
import shellStyles from './styles/shell.js';
import CampaignList from './components/campaign/campaign-list.js';

class Dashboard extends LitElement {
  static styles = shellStyles;

  constructor() {
    super();
  }

  render() {
    return html`
      <campaign-list></campaign-list>
    `;
  }
}

customElements.define('app-dashboard', Dashboard);

export default Dashboard;

