import { css } from 'lit';

/* stylelint-disable font-family-no-missing-generic-family-keyword */
const shellStyles =  css`
  :host {
    display: flex;
    flex-direction: column;
    font-family: 'Google Sans';
  }

  main {
    margin: auto 20px;
    flex-grow: 1;
  }

  app-header {
    width: 100%;
    height: 100%;
  }

  .title {
    display: flex;
    align-items: center;
    font-size: 25px;
    width: 100%;
    padding: 30px;
  }
`;
/* stylelint-enable font-family-no-missing-generic-family-keyword */

export default shellStyles;

