import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import Grid from '@mui/material/Grid';
import Button from '@mui/material/Button';
import CampaignCard from '../components/campaign/CampaignCard';
import { useFetch } from '../hooks/fetch';
import './Dashboard.scss';

const Dashboard = () => {
    const navigate = useNavigate();
    const list = useFetch("http://127.0.0.1:5000/api/v1/campaigns");

    return (
        <div className="discoverContainer">
            <h3>Discover a campaign</h3>
            <Button
                variant="contained"
                onClick={()=> navigate(`/campaign`)}
            >
                Create a new campaign
            </Button>
            <div className="campaignList">
                { 
                    !list?.length
                        ? <div>Loading...</div>
                        : (
                            <Grid container spacing={{ xs: 2, md: 3 }} columns={{ xs: 4, sm: 8, md: 12 }}>
                                {list.map((item, index) => (
                                    <Grid item xs={2} sm={4} md={4} key={index}>
                                        <CampaignCard key={index} campaign={item} />
                                    </Grid>
                                ))}
                            </Grid>
                        )
                }
            </div>
        </div>
    );
}

export default Dashboard;

