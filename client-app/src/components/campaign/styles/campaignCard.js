import { css } from 'lit';

const campaignStyles =  css`
    .card {
      border: 1px solid lightgray;
      border-radius: 5px;
      background-color: white;
      margin: 10px;
      border-radius: 10px;
      font-size: 16px;
    }

    .cardWrapper {
      margin: 10px;
      min-width: 280px;
      min-height: 250px;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
    }

    .cardName {
      font-size: 20px;
    }

    .card:nth-child(2n) {
      flex-break: after;
    }
    
    .actionWrapper {
      display: flex;
      align-items: center;
      justify-content: space-between;
      width: 100%;
    }

    .button {
      cursor: pointer;
      background: white;
      border-radius: 50px;
      border: 2px solid #2C67FF;
      padding: 20px;
      box-shadow: 0 1px 2px #ccc;
      color: #2C67FF;
      font-size: 16px;
      font-family: 'Google Sans';
    }

    .fillButton {
      cursor: pointer;
      color: white;
      background: #2C67FF;
      border-radius: 50px;
      border: 2px solid #2C67FF;
      padding: 20px;
      box-shadow: 0 1px 2px #ccc;
      font-size: 16px;
      font-family: 'Google Sans';
    }
`;

export default campaignStyles;


