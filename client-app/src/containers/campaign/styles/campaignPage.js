import { css } from 'lit';

const campaignPage =  css`
    .leftPanel,
    .rightPanel {
      width: 50%;
    }

    .about, 
    .website {
      display: flex;
      align-items: center;
      margin: 10px 0;
      border-bottom: 1px solid light-grey;
    }
    
    .circle {
      width: 50px;
      height: 50px;
      margin-right: 10px;
      background: linear-gradient(332.1deg, #86F7B1 14.81%, #2C67FF 62.34%);
      border-radius: 50px;
    }

    .campaignContainer {
      display: flex;
      align-items: center;
      justify-content: space-evenly;
    }
    
    .campaignWrapper {
      display: flex;
      align-items: flex-start;
      flex-direction: column;
      justify-content: center;
    }

    table.donationTable {
      border: 1px solid lightgray;
      border-radius: 5px;
      min-width: 640px;
      margin: 10px 0;
    }

    table.donationTable .tableHeader {
      background-color: lightgray;
    }
    
    table.donationTable .tableHeader th {
      background-color: lightgray;
      padding: 7px;
    }
    
    table.donationTable tr {
      border-bottom: 1px solid lightgray;
      padding: 7px;
    }
`;

export default campaignPage;
