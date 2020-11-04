FROM golang:1.14.4-alpine AS probr-build
WORKDIR /probr
COPY . .

RUN apk add --update npm

WORKDIR /probr/internal/view
RUN npm ci

WORKDIR /probr
COPY docker/entrypoint.sh .
ENTRYPOINT ["./entrypoint.sh"]
