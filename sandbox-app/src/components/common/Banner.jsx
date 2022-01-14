import React from 'react';
import './Banner.scss'

class Banner extends React.Component {
    constructor(props) {
        super(props);
    }

    componentDidMount() {
        console.log(this.props);
    }

    render() {
        return (
            <div className='banner'>
                This website is hosted for demo purposes only. No money will be moved by exploring these features. This is not a Google product. © 2021 Google Inc
            </div>
        );
    }
}

export default Banner;
