FROM --platform=linux/amd64 node:16

WORKDIR .

ENV PORT 8080
ENV HOST 0.0.0.0

COPY package*.json .
COPY . .

RUN npm install 
RUN npm run build

CMD ["npm start"]

