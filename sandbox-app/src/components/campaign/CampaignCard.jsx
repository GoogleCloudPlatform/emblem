import axios from "axios"
import Card from '@mui/material/Card';
import Button from '@mui/material/Button';
import { useNavigate } from 'react-router-dom';
import './CampaignCard.scss';

const CampaignCard = ({ campaign }) => {
    let navigate = useNavigate();
    
    const { id, name, description, image_url } = campaign || {};
    console.log(campaign);

    return (
        <Card variant="outlined" className={'cardContainer'}>
            <div style={{ backgroundSize: 'cover', backgroundImage: `url(${image_url})`, height: '200px' }}></div>
            <div className="cardWrapper">
                <div>
                    <div className="title">{name}</div>
                    <div className="description">{description}</div>
                </div>
                <div className="actionWrapper">
                    <Button variant="contained">Donate</Button>
                    <Button variant="outlined" onClick={()=> navigate(`/campaign/${id}`)}>Learn more</Button>
                </div>
            </div>
        </Card> 
    );
}

export default CampaignCard;
