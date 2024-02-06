# code runner
# language: python3,nodejs,java,go,c,c++,c#,ruby,php,swift,shell,rust,dart

FROM alpine:3.19.1
# set timezone to Asia/Taipei
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Taipei /etc/localtime && \
    echo "Asia/Taipei" > /etc/timezone && \
    apk del tzdata

# update apk
RUN apk update && \
    apk upgrade

# install c
RUN apk add build-base

# install python3
RUN apk add --no-cache python3 py3-pip

# install nodejs
RUN <<EOS
cd /opt
wget https://unofficial-builds.nodejs.org/download/release/v20.5.0/node-v20.5.0-linux-x64-musl.tar.gz
mkdir -p /opt/nodejs
tar -zxvf *.tar.gz --directory /opt/nodejs --strip-components=1
rm *.tar.gz
ln -s /opt/nodejs/bin/node /usr/local/bin/node
ln -s /opt/nodejs/bin/npm /usr/local/bin/npm
EOS

# install java
RUN apk add openjdk17
# install go
RUN <<EOS
echo "installing go version 1.10.3..."
apk add --no-cache --virtual .build-deps bash gcc musl-dev openssl go gcc-go
wget -O go.tgz https://go.dev/dl/go1.21.6.src.tar.gz
tar -C /usr/local -xzf go.tgz
cd /usr/local/go/src/
./make.bash
export PATH="/usr/local/go/bin:$PATH"
export GOPATH=/opt/go/
export PATH=$PATH:$GOPATH/bin
apk del .build-deps
go version
EOS

# install ruby
RUN apk add ruby

# install php
RUN apk add php

# install rust
RUN apk add rust

# install dart
RUN apk add dart-sdk

# check versions
RUN <<EOS
python3 --version
node --version
java --version
go version
ruby --version
php --version
rustc --version
dart --version
EOS