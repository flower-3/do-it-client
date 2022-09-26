FROM node:14.18

WORKDIR /app

ENV PATH /app/node_modules/.bin:$PATH

COPY package.json /app/package.json
RUN npm install

COPY . ./
RUN npm run build

CMD ["npm", "start"]