## Installing dependencies

1. Be sure `node` and `npm` are installed.
    - You can install them from the [official Node.js site](https://nodejs.org/en/)
2. Install the dependencies using `npm install`
3. If necessary, install [Playwright](https://playwright.dev) using `npx install playwright`.
    - **Playwright** is a _headless browser_ used for testing web applications

# Configure test environment
1. First, determine the URL of your running Emblem **website** instance.
2. Then, set the `EMBLEM_URL` environment variable to that URL
    ```
    export EMBLEM_URL="https://website-<HASH>.<REGION_ABBR>.a.run.app
    ```
3. To run the **smoke** tests alone, use the following command:
    ```
    npx playwright test smoke-test.spec.js
    ```
    
