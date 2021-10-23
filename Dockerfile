FROM node:16.8-alpine3.11

# Create app directory
WORKDIR /chat
ADD . /chat/

# global install & update
RUN rm yarn.lock
RUN yarn
RUN yarn build

ENV HOST 0.0.0.0
EXPOSE 3000

# start command
CMD [ "yarn", "start" ]
