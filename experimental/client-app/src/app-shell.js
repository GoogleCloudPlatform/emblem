// Copyright 2022 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
import { LitElement, html } from 'lit';
import '@material/mwc-button';
import '@material/mwc-top-app-bar';
import shellStyles from './styles/shell.js';
import Dashboard from './containers/app-dashboard.js';
import Header from './components/header/header.js';
import { initRouter } from './utils/router.js';
import { getConfig } from './utils/config.js';

class AppShell extends LitElement {
  static properties = {
    title: { type: String },
  };
  static styles = shellStyles;

  constructor() {
    super();
    const { THEME } = getConfig() || {};
    this.title = THEME === 'cymbal' ? 'Cymbal Giving' : 'Emblem Giving';
    this.state = { theme: THEME };
  }

  firstUpdated() {
    initRouter();
  }

  render() {
    const { theme } = this.state;
    return html`
      <app-header .theme=${theme}></app-header>
    `;
  }
}

customElements.define('app-shell', AppShell);

export default AppShell;