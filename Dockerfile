FROM node

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY package.json /usr/src/app/
RUN npm install
COPY . /usr/src/app

RUN npm run build
VOLUME /usr/src/app/aot

CMD [ "echo", "mycard-store" ]
