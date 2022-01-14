import React from 'react';
import { render } from 'react-dom';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Header from './components/common/Header';
import DiscoverContainer from './containers/DiscoverContainer';
import CampaignContainer from './containers/CampaignContainer';
import DonationContainer from './containers/DonationContainer';
import './App.scss'

const App = () => (
    <div className="appContainer">
        <Header />
        <div className="appWrapper">
            <BrowserRouter>
                <Routes>
                    <Route path="/" element={<DiscoverContainer />}/>
                    <Route path="/campaign/:campaignId" element={<CampaignContainer />}/>
                    <Route path="/campaign/:campaignId/donation" element={<DonationContainer />}/>
                </Routes>
            </BrowserRouter>
        </div>
    </div>
);

render(<App />, document.getElementById('root'));
