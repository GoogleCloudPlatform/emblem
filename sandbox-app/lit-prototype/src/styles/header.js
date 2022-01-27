import { css } from 'lit';

const headerStyles =  css`
      mwc-top-app-bar {
        --mdc-theme-primary: white;
        --mdc-theme-on-primary: black;
      }

      .title {
        margin: 0 auto;
      }

      .subTitle {
        font-size: 12px;
        margin: 0 auto;
      }

      .titleContainer {
        padding:10px;
      }
    `;

export default headerStyles;

