import React from 'react';
import './Header.scss'
import axios from "axios"
import AppBar from '@mui/material/AppBar';
import Toolbar from '@mui/material/Toolbar';
import IconButton from '@mui/material/IconButton';
import Typography from '@mui/material/Typography';

class Header extends React.Component {
    constructor(props) {
        super(props);
    }

    componentDidMount() {
        console.log(this.props);
    }

    render() {
        return (
            <AppBar position="static" className='header'>
                <Toolbar variant="dense">
                    <Typography variant="h6" color="inherit" component="div">
                        Cymbal Giving
                    </Typography>
                </Toolbar>
            </AppBar>
        );
    }
}

export default Header;
