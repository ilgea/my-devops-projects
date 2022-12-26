FROM node:14

# Create app directory
WORKDIR /app


COPY package*.json ./

# yarn -> npm yerine alternatifi. daha az kaynak tüketiyor. yeni yeni kullanılıyor.
RUN yarn install

# copy all files into the image
COPY . .

EXPOSE 3000

CMD ["yarn", "run", "start"]