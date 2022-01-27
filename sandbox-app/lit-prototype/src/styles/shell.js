import { css } from 'lit';

const shellStyles =  css`
      :host {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: flex-start;
        font-size: 12px;
        color: #000;
        background-color: var(--app-shell-background-color);
      }

      main {
        flex-grow: 1;
      }

      app-header {
        width: 100%;
        height: 100%;
      }

      .app-footer {
        font-size: 12px;
        align-items: center;
      }
    `;

export default shellStyles;

