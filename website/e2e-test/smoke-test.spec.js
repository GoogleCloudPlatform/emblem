// Copyright 2022 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the 'License');
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an 'AS IS' BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

const { test, expect } = require('@playwright/test');

const {EMBLEM_URL} = process.env;

const assertUrlLoads = async (page, url) => {
  // Any browser errors should cause a test failure
  page.on("console", (message) => {
    if (message.type() === "error") {
      throw message.text();
    }
  })

  // Assert the target page loads successfully
  const response = await page.goto(url, 'networkidle');
  return expect(response.status()).toBe(200)
}

test('Renders homepage', async ({ page }) => {
  await assertUrlLoads(page, EMBLEM_URL);
});

test('Renders login', async ({ page }) => {
  await assertUrlLoads(page, EMBLEM_URL + '/login');
});

test('Renders logout', async ({ page }) => {
  await assertUrlLoads(page, EMBLEM_URL + '/logout');
});

test('Renders donate', async ({ page }) => {
  await assertUrlLoads(page, EMBLEM_URL + '/donate?campaign_id=59d32e9805fc4d3388db');
});

test('Renders viewCampaign', async ({ page }) => {
  await assertUrlLoads(page, EMBLEM_URL + '/viewCampaign?campaign_id=59d32e9805fc4d3388db');
});

test('Renders createCampaign', async ({ page }) => {
  await assertUrlLoads(page, EMBLEM_URL + '/createCampaign');
});

test('Renders viewDonation', async ({ page }) => {
  await assertUrlLoads(page, EMBLEM_URL + '/viewDonation?donation_id=f5ea984abf29497bbed7');
});

// robots.txt - not working right now
// test('Renders viewDonation', async ({ page }) => {
//   await assertUrlLoads(page, EMBLEM_URL + '/robots.txt');
// });



