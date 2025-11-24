FROM scratch AS rootfs

COPY --chmod=0755 ["./set_root_password.sh", "/usr/local/bin/set_root_password.sh"]
COPY ["./supervisord.conf", "/etc/supervisord.conf"]



FROM debian:bookworm-slim

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get -y upgrade \
    && apt-get install --no-install-recommends -y supervisor openssh-server corosync-qnetd \
    && apt-get -y autoremove \
    && apt-get clean all \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && mkdir -p /run/sshd

COPY --from=rootfs ["/", "/"]

EXPOSE 22
EXPOSE 5403

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]