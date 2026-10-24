FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install && \
    npm install react-toastify@9.1.3 --save

COPY . .

EXPOSE 3000

CMD ["npm", "start"] 