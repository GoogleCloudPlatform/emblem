
export const getCampaignItem = (store, campaignId) => {
  const totalCampaigns = store.getState()?.campaigns?.campaigns; 
  return totalCampaigns.filter(campaign => campaign.id === campaignId)?.[0];
};
