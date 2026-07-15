# syntax=docker/dockerfile:1

FROM node:22 AS base
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --no-audit
COPY . .
ARG API_URL
ARG WS_URL

FROM base AS build-dev
RUN npm run build:dev

FROM base AS build-prod
RUN npm run build:prod

FROM nginx:alpine AS dev
COPY --from=build-dev /app/dist /usr/share/nginx/html

FROM nginx:alpine AS prod
COPY --from=build-prod /app/dist /usr/share/nginx/html

FROM node:22 AS dev-server
WORKDIR /app
VOLUME /app
ENV DEV_PORT=3000
EXPOSE $DEV_PORT
CMD ["npm", "run", "serve"]