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
import store from '../../stores/base.js';
import donationStyles from './styles/DonationPage.js';
import DonationForm from '../../components/form/donation.js';

const websiteIcon = new URL('../../assets/website-icon.png', import.meta.url).href;
const infoIcon = new URL('../../assets/info-icon.png', import.meta.url).href;

import '@material/mwc-tab-bar';
import '@material/mwc-tab';

class DonationPage extends connect(store)(LitElement) {
  static styles = donationStyles;

  constructor() {
    super();
  }
  
  render() {
    return html`
      <div class="donationContainer">
        ${true ? (
          html`<div class="donationWrapper">
            <h2>Donation Page</h2>
            <donation-form></donation-form>
          </div>`
        ): html`<div>loading...</div>`}
      </div>
    `;
  }
}

customElements.define('donation-page', DonationPage);

export default DonationPage;

