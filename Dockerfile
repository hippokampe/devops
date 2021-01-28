FROM alpine:3.12 as base

WORKDIR /hippokampe

RUN apk update && \
      apk add --no-cache \
      openssh-keygen \
      openssl \
      git

RUN mkdir keys && \
    ssh-keygen -t rsa -b 4096 -m PEM -f keys/jwtRS256.key && \
    openssl rsa -in keys/jwtRS256.key -pubout -outform PEM -out keys/jwtRS256.key.pub

RUN git clone https://github.com/hippokampe/api.git \
    && cd api \
    && git checkout feat-freedom

FROM golang:1.14 as compiler

WORKDIR /hippokampe

COPY --from=base /hippokampe/ /hippokampe

RUN cd api && go build -o /hippokampe/bin/main

RUN rm -rf /hippokampe/api

FROM ubuntu:focal

WORKDIR /hippokampe

COPY --from=compiler /hippokampe /hippokampe

RUN apt update && apt install -y --no-install-recommends \
    libnss3 \
    libxss1 \
    libasound2 \
    fonts-noto-color-emoji \
    libxtst6 \
    libgtk-3-0 \
    libpangocairo-1.0-0 \
    libatk1.0-0 \
    libcairo-gobject2 \
    libcairo2 \
    libgdk-pixbuf2.0-0 \
    libglib2.0-0 \
    libx11-xcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxfixes3 \
    libxi6 \
    libxrender1 \
    libfreetype6 \
    libfontconfig1 \
    libdbus-glib-1-2 \
    libdbus-1-3 \
    libxcb-shm0 \
    libpangoft2-1.0-0 \
    libxt6 \
    libpango-1.0-0 \
    ca-certificates

EXPOSE 8080

CMD ["/bin/sh", "-c", "./bin/main"]
