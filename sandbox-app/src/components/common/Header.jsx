import AppBar from '@mui/material/AppBar';
import Toolbar from '@mui/material/Toolbar';
import IconButton from '@mui/material/IconButton';
import Typography from '@mui/material/Typography';
import LoginIcon from '@mui/icons-material/Login';
import Banner from './Banner';
import './Header.scss'

import axios from "axios"


const Header = () => {
    
    const login = () => {
        axios.get(`http://127.0.0.1:5000/login`, { header: {"Access-Control-Allow-Origin": "*"}})
            .then(response => console.log(response));
    };

    return (
        <>
            <AppBar position="static" className='header'>
                <Toolbar variant="dense">
                    <Typography variant="h6" color="inherit" component="div">
                        Cymbal Giving
                    </Typography>
                    <LoginIcon onClick={() => login()} />
                </Toolbar>
            </AppBar>
            <Banner />
        </>
    );
}

export default Header;
