FROM alpine
LABEL maintainer="Aleksey @soar Smyrnov http://soar.name"

ARG bastion_username
ENV bastion_username=${bastion_username:-jumper}

ARG bastion_homedir
ENV bastion_homedir=${bastion_homedir:-/home/${bastion_username}/}

ENV DOCKERIZE_VERSION v0.6.1

RUN apk add --no-cache openssh openssl \
 && adduser -D -s /sbin/nologin -h ${bastion_homedir} ${bastion_username} \
 && passwd -u ${bastion_username} \
 && mkdir -p /var/chroot/sbin \
 && cp /sbin/nologin /var/chroot/sbin/nologin \
 && wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
 && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
 && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY rootfs /

COPY homefs ${bastion_homedir}/
RUN chown -R ${bastion_username}:${bastion_username} ${bastion_homedir} \
 && chmod -R u=rwX,og=rX ${bastion_homedir}/.ssh \
 && chmod u=rw,og=r ${bastion_homedir}/.ssh/authorized_keys || true

ONBUILD COPY homefs ${bastion_homedir}/
ONBUILD RUN chown -R ${bastion_username}:${bastion_username} ${bastion_homedir} \
         && chmod -R u=rwX,og=rX ${bastion_homedir}/.ssh \
         && chmod u=rw,og=r ${bastion_homedir}/.ssh/authorized_keys

ENTRYPOINT ["sshbastion.sh"]
EXPOSE 10022/tcp
