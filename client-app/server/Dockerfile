FROM --platform=linux/amd64 node:19.8.1 as auth-api-build

USER root
WORKDIR /usr/src/server
COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 4000

CMD ["npm", "run", "start"]
