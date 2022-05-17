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

// Retrieve sample values from database seed
const SAMPLE_DATA_PATH = '../../content-api/data/sample_data.json';
const SAMPLE_DATA = require(SAMPLE_DATA_PATH);
const SAMPLE_CAMPAIGN = SAMPLE_DATA.filter(d => d.id == '59d32e9805fc4d3388db')[0];

const {EMBLEM_URL} = process.env;

test('Lists Campaigns', async ({ page }) => {
  const { name, description } = SAMPLE_CAMPAIGN.data;

  await page.goto(EMBLEM_URL);

  const title = page.locator('.emblem-campaign-title').nth(0);
  await expect(title).toContainText(name);

  const card = page.locator('.emblem-campaign-card').nth(0);
  await expect(card).toContainText(description);
});
