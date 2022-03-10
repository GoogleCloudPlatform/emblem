const express = require('express');
const morgan = require('morgan');
const cors = require('cors');
const { createProxyMiddleware } = require('http-proxy-middleware');

// Creating express server
const app = express();

const PORT = 3000;
const HOST = 'localhost';
// TODO: Make this configurable for dev/staging/prod
const API_SERVICE_URL = 'https://api-pwrmtjf4hq-uc.a.run.app';

// Logging
app.use(morgan('dev'));
app.use(cors());

// Auth
app.use('', (req, res, next)=> {
  if(req.headers.authorization) {
    next();
  } else {
    res.sendStatus(403);
  }
});

app.use('/campaigns', createProxyMiddleware({
  target: API_SERVICE_URL,
  headers: {
    accept: "application/json",
    method: "GET",
  },
  changeOrigin: true
}));

app.use('/viewCampaign?campaign_id=:campaignId', createProxyMiddleware({
  target: API_SERVICE_URL,
  headers: {
    accept: "application/json",
    method: "GET",
  },
  changeOrigin: true
}));

// Start proxy
app.listen(PORT, HOST, () => {
  console.log(`Starting Proxy at ${HOST}:${PORT}`);
});
