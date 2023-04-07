# Build image

FROM alpine:3.14 as builder

ENV TWEMPROXY_URL https://github.com/twitter/twemproxy/releases/download/0.5.0/twemproxy-0.5.0.tar.gz

RUN apk --no-cache add alpine-sdk autoconf automake curl libtool

RUN curl -L "$TWEMPROXY_URL" | tar xzf - && \
    TWEMPROXY_DIR=$(find / -maxdepth 1 -iname "twemproxy*" | sort | tail -1) && \
    cd $TWEMPROXY_DIR && \
    autoreconf -fvi && CFLAGS="-ggdb3 -O0" ./configure --enable-debug=full && make && make install


# Main image

FROM alpine:3.14

ENV LISTEN_PORT="6380" \
    REDIS_SERVERS="127.0.0.1:6378:1,127.0.0.1:6379:1" \
    AUTO_EJECT_HOSTS="true" \
    TIMEOUT="2000" \
    SERVER_RETRY_TIMEOUT="5000" \
    SERVER_FAILURE_LIMIT="1" \
    SERVER_CONNECTIONS="40" \
    PRECONNECT="true" \
    HASH="fnv1a_64" \
    DISTRIBUTION="ketama"

RUN apk --no-cache add dumb-init

COPY --from=builder /usr/local/sbin/nutcracker /usr/local/sbin/nutcracker
COPY entrypoint.sh /usr/local/sbin/

ENTRYPOINT ["dumb-init", "--rewrite", "15:2", "--", "entrypoint.sh"]

EXPOSE $LISTEN_PORT
CMD ["nutcracker", "-c", "/etc/nutcracker.conf"]
