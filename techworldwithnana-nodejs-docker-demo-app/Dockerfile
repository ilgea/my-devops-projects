FROM node:16.20.0-alpine3.18

ENV MONGO_DB_USERNAME=admin \
    MONGO_DB_PWD=password

RUN mkdir -p /home/node-app

COPY ./app /home/node-app

# set default dir so that next commands executes in /home/app dir
WORKDIR /home/node-app

# will execute npm install in /home/app because of WORKDIR
RUN npm install

EXPOSE 3000
# no need for /home/app/server.js because of WORKDIR
CMD ["node", "server.js"]

