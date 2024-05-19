FROM --platform=linux/amd64 node:21.7.3 as auth-api-build

USER root
WORKDIR /usr/src/server
COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 4000

CMD ["npm", "run", "start"]
