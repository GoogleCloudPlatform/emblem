import { useState, useEffect } from 'react';
import axios from "axios"

export const useFetch = (url) => {
    const [data, setData] = useState(null);

    useEffect(() => {
        axios.get(url, { header: {"Access-Control-Allow-Origin": "*"} })
            .then(response => {
                setData(response?.data);    
            })
            .catch(error => {
                console.log(error);
            });
    }, [url]);

    return data;
};

export default { useFetch };
