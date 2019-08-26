FROM alpine:3.10.1 AS builder

LABEL author="qingyafan@163.com"

WORKDIR /tmp

ENV LANG=en_US.utf8

# build tools
RUN apk update && apk install build-base wget git g++ python make

# standalone command run, so we can cache the layer 
# it is a good idea when the internet is not good
RUN wget -O postgres_11_5.zip https://github.com/postgres/postgres/archive/REL_11_5.zip

# build postgres
RUN unzip postgres_11_5.zip && \
    cd postgres-REL_11_5 && \
    ./configure && \
    JOBS=12 make && \
    make install

RUN wget -O postgis_3_11.zip https://github.com/postgis/postgis/archive/3.0.0alpha4.zip

# build postgis
RUN unzip postgis_3_11.zip && \
    cd postgis-3.0.0alpha4 && \
    ./configure && \
    JOBS=12 make && \
    make install

FROM alpine:3.10.1 as base