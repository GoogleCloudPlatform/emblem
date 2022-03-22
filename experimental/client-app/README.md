# Emblem Giving frontend application

## Quicklinks
* [Requirements](requirements)
* [Getting Started](#getting-started)
* [Learning](requirements)
* [Contribution](#contribution)
* [Code of Conduct](#code-of-conduct)

## Requirements

Please have [node](https://nodejs.org/en/ ) 14 & npm 8 or higher installed.

## Get started

Within your terminal, open one tab to run the proxy and another to run the app.

```bash
npm install
npm build 
npm run server // Runs the proxy
npm start // Runs your application locally
```

- `server` runs the proxy server to target api on port `3000`
- `start` runs your app for development on port `8080`, reloading on file changes
- `start:build` runs your app after it has been built using the build command
- `build` builds your app and outputs it in your `dist` directory
- `test` runs your test suite with Web Test Runner
- `lint` runs the eslinter for your project
- `lint:css` runs the css linter (stylelint) for your project
- `format` fixes linting and formatting errors


## Learning

Want to learn more frontend [resources](docs/resources.md)? This includes tooling used for this project.

## Contribution

Interested in helping out? Follow the yellow brick road to this [guide](docs/contribution_guide.md).

## Code of Conduct

Please read through our [code of conduct](docs/code_of_conduct.md)

