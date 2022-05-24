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

import { LitElement, html, css } from 'lit';
import '@material/mwc-top-app-bar';
import '@material/mwc-icon-button';
import headerStyles from './styles/header.js';
import { getConfig } from '../../utils/config.js';

const cloudLogo = new URL('../../../assets/google-cloud-logo.png', import.meta.url).href;
const cymbalGivingLogo = new URL('../../../assets/cymbal-giving-logo.png', import.meta.url).href;

class Header extends LitElement {
  static properties = {
    theme: { type: String },
  };
  static styles = headerStyles;
  
  render() {
    const { API_URL } = getConfig();

    const sessionId = document.cookie.match(/session_id=[^;]+/);
    
    return html`
      <div class="headerContainer">
        ${this.theme === 'cymbal'
          ? html`<img class="cymbalGivingLogo" src=${cymbalGivingLogo}></img>` 
          : html`<div>Emblem Giving</div>`
        }
        <div class="headerWrapper">
          <div class="cloudLogoWrapper">
            <p>Powered by</p>
            <img class="cloudLogo" src=${cloudLogo}></img>
          </div>
          <mwc-icon-button icon="help_outline" slot="actionItems"></mwc-icon-button>
          <mwc-icon-button icon="notifications" slot="actionItems"></mwc-icon-button>
          ${sessionId
            ? html`<a href=${`/auth/logout`}>
                <mwc-icon-button icon="logout" slot="actionItems" class="login"></mwc-icon-button>
              </a>`
            : html`<a href=${`/auth/login`}>
                <mwc-icon-button icon="person_outline" slot="actionItems" class="logout"></mwc-icon-button>
              </a>`
          }
        </div>
      </div>
      <div class="banner">
        This website is hosted for demo purposes only. No money will be moved by exploring these features. This is not a Google product. © 2022 Google Inc
      </div>
    `;
  }
}

customElements.define('app-header', Header);

export default Header;
