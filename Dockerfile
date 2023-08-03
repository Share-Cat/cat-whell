# code runner
# language: python3,nodejs,java,go,c,c++,c#,ruby,php,swift,shell,rust,dart

FROM alpine:3.18.2
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
WORKDIR /opt
RUN wget https://unofficial-builds.nodejs.org/download/release/v20.5.0/node-v20.5.0-linux-x64-musl.tar.gz
RUN mkdir -p /opt/nodejs
RUN tar -zxvf *.tar.gz --directory /opt/nodejs --strip-components=1
RUN rm *.tar.gz
RUN ln -s /opt/nodejs/bin/node /usr/local/bin/node
RUN ln -s /opt/nodejs/bin/npm /usr/local/bin/npm


# install java

# install go

# install ruby
RUN apk add ruby

# install php
RUN apk add php

# install swift


# install rust
RUN apk add rust

# install dart

# install shell

# install c#
