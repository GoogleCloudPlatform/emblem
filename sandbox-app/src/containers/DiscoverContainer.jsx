import React, { useState, useEffect } from 'react';
import Grid from '@mui/material/Grid';
import CampaignCard from '../components/campaign/CampaignCard';
import { useFetch } from '../hooks/fetch';

const DiscoverContainer = () => {
    const list = useFetch("http://127.0.0.1:5000/api/v1/campaigns");

    return (
        <div className="discover-container">
            <h3>Discover a campaign</h3>
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
    );
}

export default DiscoverContainer;

