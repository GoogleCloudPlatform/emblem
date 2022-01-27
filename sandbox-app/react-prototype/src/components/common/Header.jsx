import { useNavigate } from 'react-router-dom';
import AppBar from '@mui/material/AppBar';
import Toolbar from '@mui/material/Toolbar';
import IconButton from '@mui/material/IconButton';
import Typography from '@mui/material/Typography';
import LoginIcon from '@mui/icons-material/Login';
import Banner from './Banner';
import './Header.scss'

import axios from "axios"


const Header = () => {
    const navigate = useNavigate(); 
    const login = () => {
        axios.get(`http://127.0.0.1:5000/login`, { header: {"Access-Control-Allow-Origin": "*"}})
            .then(response => console.log(response));
    };

    return (
        <>
            <AppBar position="static">
                <div className='header'>
                    <div onClick={() => { navigate('/');}}>
                        <h2 className="title">Cymbal Giving</h2>
                        <p className="subTitle">a Cymbal Fintech company</p>
                    </div>
                    <IconButton><LoginIcon onClick={() => login()} /></IconButton>
                </div>
            </AppBar>
            <Banner />
        </>
    );
}

export default Header;
