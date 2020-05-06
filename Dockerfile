FROM alpine
LABEL maintainer="Aleksey @soar Smyrnov http://soar.name"

ARG BASTION_USERNAME
ENV BASTION_USERNAME=${BASTION_USERNAME:-jumper}

ARG BASTION_HOMEDIR
ENV BASTION_HOMEDIR=${BASTION_HOMEDIR:-/home/${BASTION_USERNAME}/}

ENV DOCKERIZE_VERSION v0.6.1

RUN apk add --no-cache openssh openssl \
 && adduser -D -s /sbin/nologin -h ${BASTION_HOMEDIR} ${BASTION_USERNAME} \
 && passwd -u ${BASTION_USERNAME} \
 && mkdir -p /var/chroot/sbin \
 && cp /sbin/nologin /var/chroot/sbin/nologin \
 && wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
 && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
 && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY rootfs /

COPY homefs ${BASTION_HOMEDIR}/
RUN chown -R ${BASTION_USERNAME}:${BASTION_USERNAME} ${BASTION_HOMEDIR} \
 && chmod -R u=rwX,og=rX ${BASTION_HOMEDIR}/.ssh \
 && chmod u=rw,og=r ${BASTION_HOMEDIR}/.ssh/authorized_keys || true

ONBUILD COPY homefs ${BASTION_HOMEDIR}/
ONBUILD RUN chown -R ${BASTION_USERNAME}:${BASTION_USERNAME} ${BASTION_HOMEDIR} \
         && chmod -R u=rwX,og=rX ${BASTION_HOMEDIR}/.ssh \
         && chmod u=rw,og=r ${BASTION_HOMEDIR}/.ssh/authorized_keys

ENTRYPOINT ["sshbastion.sh"]
EXPOSE 10022/tcp
