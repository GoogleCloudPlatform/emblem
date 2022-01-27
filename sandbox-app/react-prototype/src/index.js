import React from 'react';
import { render } from 'react-dom';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Header from './components/common/Header';
import Dashboard from './containers/Dashboard';
import CampaignContainer from './containers/campaign/CampaignContainer';
import NewCampaignContainer from './containers/campaign/NewCampaignContainer';
import NewDonationContainer from './containers/donation/NewDonationContainer';
import './index.scss'

const App = () => (
    <div className="appContainer">
        <BrowserRouter>
            <Header />
            <div className="appWrapper">
                <Routes>
                    <Route path="/" element={<Dashboard />}/>
                    <Route exact path="/campaign" element={<NewCampaignContainer />}/>
                    <Route path="/campaign/:campaignId" element={<CampaignContainer />}/>
                    <Route path="/campaign/:campaignId/donation" element={<NewDonationContainer />}/>
                </Routes>
            </div>
        </BrowserRouter>
    </div>
);

render(<App />, document.getElementById('root'));
