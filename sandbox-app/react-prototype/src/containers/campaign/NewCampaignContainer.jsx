import { useState, useEffect } from 'react';
import Button from '@mui/material/Button';
import CampaignForm from '../../components/campaign/CampaignForm';

const NewCampaignContainer = () => {
    return (
        <div className="container">
            <CampaignForm />
        </div>
    );
}

export default NewCampaignContainer;
