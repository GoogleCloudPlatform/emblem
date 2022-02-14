import { LitElement, html } from 'lit';
import '@material/mwc-button';
import '@material/mwc-top-app-bar';
import shellStyles from './styles/shell.js';

const logo = new URL('../assets/open-wc-logo.svg', import.meta.url).href;

class AppShell extends LitElement {
  static properties = {
    title: { type: String },
  };
  
  static styles = shellStyles;

  constructor() {
    super();
    this.title = 'Cymbal Giving';
  }

  render() {
    return html`
      <app-header></app-header>
      <main>
        <campaign-list>
        </campaign-list>
      </main>
      <p class="app-footer">
        Emblem prototype
      </p>
    `;
  }
}

export default AppShell;

