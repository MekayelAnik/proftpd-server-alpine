# Use Alpine Linux
ARG ALPINE_VERSION=latest
FROM alpine:$ALPINE_VERSION
ARG TZ=Asia/Dhaka
ARG FTP_GID=48 
ARG FTP_UID=48
ENV ALLOW_OVERWRITE=on \
    ANONYMOUS_DISABLE=on \
    ANON_UPLOAD_ENABLE=DenyAll \
    LOCAL_ROOT=~ \
    LOCAL_UMASK=022 \
    MAX_CLIENTS=100 \
    MAX_INSTANCES=100 \
    SERVER_NAME=ProFTPD \
    TIMES_GMT=off \
    FTP_PORT=21 \
    WRITE_ENABLE=AllowAll \
    NUMBER_OF_SHARES=1 \
    FTP_SHARE_1=sahre1 \
    FTP_PASSWORD_1=password1 \
    TIMEOUT_IDLE=600 \
    TIMEOUT_NO_TRANSFER=300 \
    TIMEOUT_STALLED=3600

RUN set -x \
   addgroup -g ${FTP_GID} ftp \
   adduser -H -h /run/proftpd -s /bin/false --uid ${FTP_UID} -g 'ftp daemon' ftp \
   addgroup ftp ftp \
  ;

RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk --update-cache --no-cache upgrade && \
    apk add --update-cache --no-cache shadow proftpd openssl less bash tzdata  && \
    mkdir -p /run/proftpd  && \
    rm -rf /var/cache/apk/*

COPY --chmod=555 proftpd.conf /etc/proftpd
COPY --chmod=555 proftpd.sh /usr/bin
COPY --chmod=555 proftpd.delay /run/proftpd
COPY --chmod=555 banner.sh /usr/bin
COPY --chmod=444 build-timestamp /usr/bin


# Passive Ports 
EXPOSE 4559-4564/tcp

ENTRYPOINT ["/usr/bin/proftpd.sh"]
# Define service entrypoint
CMD ["proftpd", "--nodaemon"]
