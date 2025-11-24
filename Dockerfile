ARG COROSYNC_QNETD_VERSION=3.0.3-2
ARG DEBIAN_DISTRO=trixie

FROM scratch AS rootfs

# Install s6 overlay and docker-env-secrets support
COPY --from=ghcr.io/n0rthernl1ghts/s6-rootfs:3.2.0.2 ["/", "/"]
COPY --from=ghcr.io/n0rthernl1ghts/docker-env-secrets:latest ["/", "/"]

# Copy rootfs overlay
COPY ["/rootfs/", "/"]



ARG DEBIAN_DISTRO
FROM debian:${DEBIAN_DISTRO}-slim

ARG COROSYNC_QNETD_VERSION
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get -y upgrade \
    && apt-get install --no-install-recommends -y openssh-server "corosync-qnetd=${COROSYNC_QNETD_VERSION}" \
    && apt-get -y autoremove \
    && apt-get clean all \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && mkdir -p /run/sshd

COPY --from=rootfs ["/", "/"]


ENV S6_KEEP_ENV=0 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2


EXPOSE 22
EXPOSE 5403

ENTRYPOINT ["/init"]