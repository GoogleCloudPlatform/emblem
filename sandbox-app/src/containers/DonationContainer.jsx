import { useState, useEffect } from 'react';
import Button from '@mui/material/Button';
import CampaignCard from '../components/campaign/CampaignCard';
import DonationTable from '../components/donation/DonationTable';
import { useParams } from 'react-router-dom';
import { useFetch } from '../hooks/fetch';
import './DonationContainer.scss';

const DonationContainer = () => {
    let { campaignId } = useParams();
    
    const campaign = useFetch(`http://127.0.0.1:5000/api/v1/get_campaign?campaign_id=${campaignId}`);
    const { name, cause, description, formattedDateCreated, formattedDateUpdated } = campaign || {};
    
    return (
        <div className="DonationContainer">
            <div className="leftPanel">
                <>
                    <h2 className="title">{name}</h2>
                    <h3 className="description">{description}</h3>
                    <Button variant="contained">Edit campaign</Button>
                </>
                <div className="section">
                    <div className="circle"></div> 
                    <div>
                        <p>About this cause</p>
                        <p>{description}</p>
                    </div>
                </div>
                <div className="section">
                    <div className="circle"></div> 
                    <div>
                        <div>Website</div>
                        <a href="#">https://google.com</a>
                    </div>
                </div>
                <div>
                    <div>Donation History</div>
                    <DonationTable />
                </div>
                <Button variant="contained">Make a donation</Button>
            </div> 
            <div className="rightPanel">
                <CampaignCard campaign={campaign}/>
            </div> 
        </div>
    );
}

export default DonationContainer;
