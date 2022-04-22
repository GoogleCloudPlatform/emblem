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

test('Lists Campaigns', async ({ page }) => {
  // Values retrieved from seeding database
  // https://github.com/GoogleCloudPlatform/emblem/blob/main/content-api/data/sample_data.json
  //SAMPLE_CAMPAIGN_NAME = 'Books for Ostriches needs your help!';
  //SAMPLE_CAMPAIGN_DESCRIPTION = 'This time of year, Books for Ostriches could really use your help. Donate to my campaign to raise funds for Books for Ostriches today!'

  // Values for our staging website
  SAMPLE_CAMPAIGN_NAME = 'Cash for Camels';
  SAMPLE_CAMPAIGN_DESCRIPTION = 'Support Camels';

  await page.goto(EMBLEM_URL);

  const title = page.locator('.emblem-campaign-title').nth(0);
  await expect(title).toContainText(SAMPLE_CAMPAIGN_NAME);

  const card = page.locator('.emblem-campaign-card').nth(0);
  await expect(card).toContainText(SAMPLE_CAMPAIGN_DESCRIPTION);
});
