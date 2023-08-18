# Use Alpine Linux
ARG ALPINE_VERSION=latest
FROM alpine:$ALPINE_VERSION
ARG TZ=Asia/Dhaka
ARG FTP_GID=48 
ARG FTP_UID=48
RUN date +%c > /build-timestamp
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
    FTP_USERNAME_1=user1 \
    FTP_PASSWORD_1=password1 \
    FTP_USER_1_PUID=1000 \
    FTP_USER_1_PGID=1000
RUN set -x \
   addgroup -g ${FTP_GID} ftp \
   adduser -H -h /run/proftpd -s /bin/false --uid ${FTP_UID} -g 'ftp daemon' ftp \
   addgroup ftp ftp \
  ;

RUN apk add --update --no-cache shadow proftpd openssl less bash tzdata

RUN mkdir -p /run/proftpd
COPY --chmod=555 proftpd.conf /etc/proftpd
COPY --chmod=555 proftpd.sh /usr/bin
COPY --chmod=555 proftpd.delay /run/proftpd
COPY --chmod=444 build-timestamp /usr/bin
RUN apk --update --no-cache upgrade && \
    rm -f /bin/netstat && \
    rm -rf /var/cache/apk/*

# FTP default port
EXPOSE 21/tcp

# Passive Ports 
EXPOSE 4559-4564/tcp

# Configuration volumes
VOLUME ["/etc/proftpd", "/srv"]

# Data volumes
VOLUME ["/samba-shares"]

ENTRYPOINT ["/usr/bin/proftpd.sh"]
# Define service entrypoint
CMD ["proftpd", "--nodaemon"]
