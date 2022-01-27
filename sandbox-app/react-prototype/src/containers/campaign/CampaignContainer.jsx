import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import Button from '@mui/material/Button';
import CampaignCard from '../../components/campaign/CampaignCard';
import DonationTable from '../../components/donation/DonationTable';
import { useFetch } from '../../hooks/fetch';
import './CampaignContainer.scss';

const CampaignContainer = () => {
    const navigate = useNavigate();
    let { campaignId } = useParams();
    
    const campaign = useFetch(`http://127.0.0.1:5000/api/v1/get_campaign?campaign_id=${campaignId}`);
    const { name, cause, description, formattedDateCreated, formattedDateUpdated } = campaign || {};
    
    return (
        <div className="campaignContainer">
            <div className="leftPanel">
                <h2 className="title">{name}</h2>
                <h3 className="description">{description}</h3>
                <Button variant="contained" sx={{ marginRight: '5px' }}>Edit campaign</Button>
                <Button
                    variant="contained"
                    onClick={()=> navigate(`/campaign/${campaignId}/donation`)}
                >
                    Make a donation
                </Button>
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
            </div> 
            <div className="rightPanel">
                <CampaignCard campaign={campaign}/>
            </div> 
        </div>
    );
}

export default CampaignContainer;
