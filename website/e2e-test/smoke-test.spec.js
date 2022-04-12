const { test, expect } = require('@playwright/test');

const EMBLEM_URL = 'http://localhost:8080'

test('Renders homepage', async ({ page }) => {
  await page.goto(EMBLEM_URL);
  const title = page.locator('.navbar__inner .navbar__title');
  await expect(page).toHaveTitle(/View Campaigns/i);
});
