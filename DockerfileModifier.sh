#!/bin/bash

# Define variables
REPO_NAME='proftpd-server-alpine'
DOCKERFILE_NAME="./Dockerfile.${REPO_NAME}"
STABLE_ALPINE_VERSION="latest"
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

cat <<EOF > "${DOCKERFILE_NAME}"
# Use Alpine Linux - Using a stable version for reliability
FROM alpine:${STABLE_ALPINE_VERSION}

# Define build arguments
ARG TZ="Asia/Dhaka"
ARG PROFTPD_GID=48
ARG PROFTPD_UID=48

# Define an ARG to hold the version
ARG PROFTPD_VERSION="unknown"

# Set environment variables
ENV ALLOW_OVERWRITE=on \\
    ANONYMOUS_DISABLE=on \\
    ANON_UPLOAD_ENABLE=DenyAll \\
    LOCAL_ROOT=~ \\
    LOCAL_UMASK=022 \\
    MAX_CLIENTS=100 \\
    MAX_INSTANCES=100 \\
    SERVER_NAME=ProFTPD \\
    TIMES_GMT=off \\
    FTP_PORT=21 \\
    WRITE_ENABLE=AllowAll \\
    NUMBER_OF_SHARES=1 \\
    FTP_SHARE_1=share1 \\
    FTP_PASSWORD_1=password1 \\
    TIMEOUT_IDLE=600 \\
    TIMEOUT_NO_TRANSFER=300 \\
    TIMEOUT_STALLED=3600

# --- CORE OPTIMIZATION: Single layer installation ---
RUN apk update && \\
    export PROFTPD_VERSION=\$(apk search --print-ver proftpd) && \\
    /bin/echo "PROFTPD_VERSION=\${PROFTPD_VERSION}" >> /etc/profile.d/proftpd_version.sh && \\
    apk --upgrade add shadow proftpd openssl less bash tzdata && \\
    rm -rf /var/cache/apk/* /tmp/* && \\
    if ! getent group ftp > /dev/null 2>&1; then \\
        addgroup -g \${PROFTPD_GID} ftp; \\
    fi && \\
    if ! getent passwd ftp > /dev/null 2>&1; then \\
        adduser -H -h /run/proftpd -s /bin/false --uid "\${PROFTPD_UID}" -G ftp -D ftp; \\
    fi && \\
    mkdir -p /run/proftpd && \\
    chown ftp:ftp /run/proftpd && \\
    touch /run/proftpd/proftpd.delay && \\
    chmod 555 /run/proftpd/proftpd.delay && \\
    mkdir -p /etc/proftpd && \\
    touch /etc/proftpd/proftpd.conf && \\
    chmod 555 /etc/proftpd/proftpd.conf

# Use the dynamically captured version in the final LABEL
LABEL org.opencontainers.image.created="${BUILD_DATE}" \\
    org.opencontainers.image.version="\${PROFTPD_VERSION}" \\
    org.opencontainers.image.authors="MUHAMMAD MEKAYEL ANIK <mekayel.anik@gmail.com>" \\
    org.opencontainers.image.source="https://github.com/MekayelAnik/proftpd-server-alpine" \\
    org.opencontainers.image.licenses="GPL-3.0" \\
    org.opencontainers.image.title="ProFTPD Server Alpine" \\
    org.opencontainers.image.description="ProFTPD server container based on Alpine Linux"

# Add local resources AFTER package installation to prevent cache invalidation
ADD --chmod=555 ./resources /usr/bin

# Expose FTP ports
EXPOSE 21
EXPOSE 4559-4564/tcp

# Define service entrypoint
ENTRYPOINT ["/usr/bin/proftpd.sh"]

# Default command
CMD ["proftpd", "--nodaemon"]
EOF

echo "Successfully generated the final, optimized Dockerfile content in ${DOCKERFILE_NAME}"
echo "Note: The Dockerfile is configured to capture the ProFTPD version (\$(apk search --print-ver proftpd)) during the build."