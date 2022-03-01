import { css } from 'lit';

const shellStyles =  css`
  :host {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: flex-start;
    font-family: 'Google Sans';
    font-size: 12px;
    color: #000;
    background-color: #fff;
  }

  main {
    margin: auto 20px;
    flex-grow: 1;
  }

  app-header {
    width: 100%;
    height: 100%;
  }
`;

export default shellStyles;

