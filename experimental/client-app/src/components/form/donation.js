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
import donationFormStyles from './styles/donationForm.js';

import '@material/mwc-button';
import '@material/mwc-textfield';

class DonationForm extends LitElement {
  static properties = {
    onSubmit: {type: Function},
  };

  static styles = donationFormStyles;

  constructor() {
    super();
    this.onSubmit = () => {};
    this.submitForm = this.submitForm.bind(this);
  }

  submitForm(e) {
    e && e.preventDefault();
    this.onSubmit(this.shadowRoot.querySelector("form"));
  }

  render() {
    return html`<form @submit=${this.submitForm}>
      <div class="formControls">
        <mwc-textfield outline name="amount" type="number" label="Amount" helper="Donation amount in dollars"></mwc-textfield>
        <mwc-textfield outline name="name" type="text" label="Donor name" helper="Donor name"></mwc-textfield>
        <mwc-textfield outline name="address" type="text" label="Donor address" helper="Donor address"></mwc-textfield>
        <mwc-textfield outline name="city" type="text" label="Donor city" helper="Donor city"></mwc-textfield>
        <mwc-textfield outline name="state" type="text" label="Donor state" helper="Donor state"></mwc-textfield>
        <mwc-textfield outline name="zipcode" type="number" label="Donor zipcode" helper="Donor zipcode"></mwc-textfield>
        <button type="submit" class="fillButton button">Donate</button>
      </div>
    </form>`;
  }
}

customElements.define("donation-form", DonationForm);

export default DonationForm;
