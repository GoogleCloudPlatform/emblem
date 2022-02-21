import { css } from 'lit';

const headerStyles =  css`
      mwc-top-app-bar {
        --mdc-theme-primary: white;
        --mdc-theme-on-primary: black;
        box-shadow: 0 0 5px #ccc;
      }

      .banner {
        background-color: #306DFD;
        padding: 25px;
        color: white;
        font-size: 16px;
        line-height: 24px;
        display: flex;
        align-items: center;
        justify-content: center;
        text-align: center;
        box-shadow: 0 0 8px #ccc;
        margin-bottom: 10px;
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

