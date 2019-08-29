FROM alpine:3.10.2 AS builder

LABEL author="qingyafan@163.com"

WORKDIR /tmp

ENV LANG=en_US.utf8

# build tools
RUN apk update && \
    apk add build-base \
            wget \
            gcc \
            perl \
            make \
            bison \
            flex \
            readline-dev \
            zlib-dev

# standalone command run, so we can cache the layer 
# it is a good idea when the internet is not good
RUN wget -O postgres_11_5.zip https://github.com/postgres/postgres/archive/REL_11_5.zip

# build postgres
# TODO: --with-llvm 
RUN unzip postgres_11_5.zip && \
    cd postgres-REL_11_5 && \
    ./configure && \
    JOBS=12 make && \
    make install

RUN wget -O postgis_25_11.tar.gz https://download.osgeo.org/postgis/source/postgis-2.5.3.tar.gz

RUN apk add libxml2-dev \
            geos-dev

# TODO:
# dep on geos which alpine 3.10 does not have a dist
# should build it first

# build postgis
# not yet finish
RUN tar zxvf postgis_25_11.tar.gz && \
    cd postgis-2.5.3 && \
    ./configure --with-pgconfig=/usr/local/pgsql/bin/pg_config && \
    JOBS=12 make && \
    make install

# final installation
FROM alpine:3.10.2 as base

WORKDIR /tmp

COPY --from=builder /usr/local/pgsql /usr/local/

ENV LANG=en_US.utf8
ENV PATH=$PATH:/usr/local/pgsql/bin

RUN mkdir -p /var/lib/pgsql/11/data && \
    chown -R postgres:postgres /var/lib/pgsql/11/data && \
    touch /home/logfile && \
    chown postgres:postgres /home/logfile && \
    su postgres && \
    initdb -D /var/lib/pgsql/11/data && \
    pg_ctl -D /var/lib/pgsql/11/data -l logfile start
