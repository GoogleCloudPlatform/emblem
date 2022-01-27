import { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import CampaignCard from '../../components/campaign/CampaignCard';
import DonationForm from '../../components/donation/DonationForm';
import DonationTable from '../../components/donation/DonationTable';
import { useFetch } from '../../hooks/fetch';
import './DonationContainer.scss';

const NewDonationContainer = () => {
    let { campaignId } = useParams();
    
    const campaign = useFetch(`http://127.0.0.1:5000/api/v1/get_campaign?campaign_id=${campaignId}`);
    return (
        <div className="DonationContainer">
            <DonationForm campaign={campaign} />
        </div>
    );
}

export default NewDonationContainer;
