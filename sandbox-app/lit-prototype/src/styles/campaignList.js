import { css } from 'lit';

const campaignStyles =  css`
    .campaignList {
      display: flex;
      align-items: center;
      justify-content: center;
      flex-wrap: wrap;
    }

    .card {
      border: 1px solid lightgray;
      border-radius: 5px;
      background-color: white;
      margin: 10px;
      padding: 6px;
    }

    .cardName {
      font-size: 20px;
    }

    .card:nth-child(2n) {
      flex-break: after;
    }
`;

export default campaignStyles;


