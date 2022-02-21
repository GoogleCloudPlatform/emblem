FROM node:10

WORKDIR .

ENV PORT 8000
ENV HOST 0.0.0.0

COPY package*.json ./

RUN npm install 
RUN npm build 

COPY . .

CMD npm start
