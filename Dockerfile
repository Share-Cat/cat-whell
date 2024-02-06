FROM alpine:3.19.1

RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Taipei /etc/localtime && \
    echo "Asia/Taipei" > /etc/timezone && \
    apk del tzdata && \
    apk update && \
    apk upgrade && \
    apk add --no-cache build-base && \
    apk add --no-cache python3 py3-pip && \
    apk add --no-cache openjdk17 && \
    apk add --no-cache ruby && \
    apk add --no-cache php && \
    apk add --no-cache rust && \
    apk add --no-cache dart-sdk

# install nodejs
RUN cd /opt && \
    wget https://unofficial-builds.nodejs.org/download/release/v20.5.0/node-v20.5.0-linux-x64-musl.tar.gz && \
    mkdir -p /opt/nodejs && \
    tar -zxvf *.tar.gz --directory /opt/nodejs --strip-components=1 && \
    rm *.tar.gz && \
    ln -s /opt/nodejs/bin/node /usr/local/bin/node && \
    ln -s /opt/nodejs/bin/npm /usr/local/bin/npm

# install go
COPY --from=golang:alpine3.19 /usr/local/go/ /usr/local/go/
ENV PATH="/usr/local/go/bin:${PATH}"

RUN apk purge --no-cache tzdata && \
    rm -rf /var/cache/apk/*

# check versions
RUN python3 --version && \
    node --version && \
    java --version && \
    go version && \
    ruby --version && \
    php --version && \
    rustc --version && \
    dart --version