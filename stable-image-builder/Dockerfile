# Use Alpine Linux
ARG ALPINE_VERSION=edge
FROM alpine:$ALPINE_VERSION
ARG FTP_GID=48 
ARG FTP_UID=48
ARG TZ=Asia/Dhaka

LABEL author="MUHAMMAD MEKAYEL ANIK"
LABEL author_email="mekayel.anik@gmail.com"
LABEL github_url="https://github.com/MekayelAnik/samba-server-alpine"
LABEL licence="GPL-3.0"

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
    mkdir -p /run/proftpd && \
    touch /run/proftpd/proftpd.delay && \
    chmod 555 /run/proftpd/proftpd.delay && \
    touch /etc/proftpd/proftpd.conf && \
    chmod 555 /etc/proftpd/proftpd.conf && \
    rm -rf /var/cache/apk/*

ADD --chmod=555 ./scripts  /usr/bin

# Passive Ports 
EXPOSE 4559-4564/tcp

ENTRYPOINT ["/usr/bin/proftpd.sh"]
# Define service entrypoint
CMD ["proftpd", "--nodaemon"]
