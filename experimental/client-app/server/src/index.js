import express from "express";
import jwt from "jsonwebtoken";
import axios from "axios";
import cors from "cors";
import querystring from "querystring";
import cookieParser from "cookie-parser";
import {
  CLIENT_ID,
  JWT_SECRET,
  CLIENT_SECRET,
  COOKIE_NAME,
  REDIRECT_URI,
  SITE_URL,
} from "./config.js";

const port = 4000;
const redirectURI = "/auth/google";
const app = express();

function getTokens({
  code,
  clientId,
  clientSecret,
  redirectUri,
}) {
  const url = "https://oauth2.googleapis.com/token";
  const values = {
    code,
    client_id: clientId,
    client_secret: clientSecret,
    redirect_uri: redirectUri,
    grant_type: "authorization_code",
  };

  const options = {
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
  };

  return axios.post(url, querystring.stringify(values), options)
    .then((res) => res.data)
    .catch((error) => {
      console.error(`Failed to fetch auth tokens`);
      throw new Error(error.message);
    });
}

/**
 * Applying cors
 * Origin: applies access-control-allow-origin to client app
 * Client: applies access-control-allow-credentials to true
 */ 
app.use(
  cors({
    origin: SITE_URL,
    credentials: true,
  })
);

app.use(cookieParser());

/**
 * Retrieve Google Auth Login URL
 */ 
app.get("/getLoginURL", (req, res) => res.send(getGoogleAuthURL()));

/**
 * Handle Auth Callback
 */ 
app.get(`${redirectURI}`, async (req, res) => {
  const code = req.query.code;

  const { id_token, access_token } = await getTokens({
    code,
    clientId: CLIENT_ID,
    clientSecret: CLIENT_SECRET,
    redirectUri: `${REDIRECT_URI}`
  });

  const userURL = `https://www.googleapis.com/oauth2/v1/userinfo?alt=json&access_token=${access_token}`;
  const options = {
    headers: {
      Authorization: `Bearer ${id_token}`,
    },
  };

  const user = await axios.get(userURL, options)
    .then((res) => res.data)
    .catch((error) => {
      console.error(`Failed to fetch user`);
      throw new Error(error.message);
    });

  const token = jwt.sign(user, JWT_SECRET);

  res.cookie(COOKIE_NAME, token, {
    maxAge: 900000,
    httpOnly: true,
    secure: false,
  });

  return res.redirect(SITE_URL);
});

/**
 * Retrieve logged in user profile
 */ 
app.get("/getUser", (req, res) => {
  let user;
  try {
    const cookie = req.cookies[COOKIE_NAME];
    const decoded = jwt.verify(req.cookies[COOKIE_NAME], JWT_SECRET);
  } catch (err) {
    throw new Error(error);
  }
  return res.send(user);
});

/**
 * Check for auth cookie
 */ 
app.get("/hasCookie", (req, res) => {
  let cookie;
  try {
    cookie = req.cookies[COOKIE_NAME];
  } catch (err) {
    res.send(false);
  }
  return res.send(!!cookie);
});

/**
 * Handle auth logout
 */ 
app.get("/logout", (req, res) => {
  try {
    const cookie = req.cookies[COOKIE_NAME];
    res.clearCookie(COOKIE_NAME); 
  } catch (err) {
    throw new Error(error.message);
  }
  res.send('logout completed');
});

app.listen(port, () => {
  console.log(`Auth api server listening http://localhost:${port}`);
});
