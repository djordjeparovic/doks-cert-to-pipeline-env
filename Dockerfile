FROM digitalocean/doctl:1.27.0

RUN apk add --no-cache openssl jq bash

WORKDIR /app

COPY ./scripts .

ENTRYPOINT ["./update-cert.sh"]
