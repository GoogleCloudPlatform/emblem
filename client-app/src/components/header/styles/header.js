import { css } from 'lit';

const headerStyles =  css`
      .cloudLogo {
        height: 25px;
      }

      .cymbalGivingLogo {
        height: 100px;
      }

      .headerContainer {
        display: flex;
        align-items: center;
        justify-content: space-between;
        color: #606367;
      }

      .headerWrapper {
        display: flex;
        align-items: center;
      }

      .cloudLogoWrapper {
        display: flex;
        flex-direction: column;
      }
      
      .cloudLogoWrapper p {
        margin: 5px 0;
        font-size: 18px;
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
    `;

export default headerStyles;

