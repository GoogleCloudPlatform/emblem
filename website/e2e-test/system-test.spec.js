const { test, expect } = require('@playwright/test');

const EMBLEM_URL = 'http://localhost:8080'

test('Lists Campaigns', async ({ page }) => {
  // Values retrieved from seeding database
  // https://github.com/GoogleCloudPlatform/emblem/blob/main/content-api/data/sample_data.json
  //SAMPLE_CAMPAIGN_NAME = 'Books for Ostriches needs your help!';
  //SAMPLE_CAMPAIGN_DESCRIPTION = 'This time of year, Books for Ostriches could really use your help. Donate to my campaign to raise funds for Books for Ostriches today!'

  // Values for Ace's laptop :)
  SAMPLE_CAMPAIGN_NAME = 'Take the Trash Out';
  SAMPLE_CAMPAIGN_DESCRIPTION = "It's your turn!";

  await page.goto(EMBLEM_URL);

  const title = page.locator('.emblem-campaign-title').nth(0);
  await expect(title).toContainText(SAMPLE_CAMPAIGN_NAME);

  const card = page.locator('.emblem-campaign-card').nth(0);
  await expect(card).toContainText(SAMPLE_CAMPAIGN_DESCRIPTION);
});
