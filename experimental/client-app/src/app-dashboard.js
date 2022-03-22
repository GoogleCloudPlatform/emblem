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
import { connect } from 'pwa-helpers/connect-mixin.js';
import shellStyles from './styles/shell.js';
import CampaignList from './components/campaign/campaign-list.js';

class Dashboard extends LitElement {
  static styles = shellStyles;

  constructor() {
    super();
  }

  render() {
    return html`
      <div class="title">
        Discover a cause or a campaign
      </div>
      <campaign-list></campaign-list>
    `;
  }
}

customElements.define('app-dashboard', Dashboard);

export default Dashboard;

