#!/bin/sh -e

HOST_KEY_TYPES="dsa ed25519 ecdsa rsa"
SECRETSDIR=/run/secrets
HOST_KEYS_DIR=/etc/ssh

for host_key_type in ${HOST_KEY_TYPES}; do
    keyfilename="ssh_host_${host_key_type}_key"

    if [ -r "${SECRETSDIR}/${keyfilename}" ]; then
        echo "Precreated key ${keyfilename} found, will be used as host key..."
        if [ "$COPY_KEYS" ]; then
            cp "${SECRETSDIR}/${keyfilename}" "${HOST_KEYS_DIR}/${keyfilename}"
            chmod 0400 "${HOST_KEYS_DIR}/${keyfilename}"
        else
            ln -s "${SECRETSDIR}/${keyfilename}" "${HOST_KEYS_DIR}/${keyfilename}"
        fi
        ssh-keygen -y -f "${HOST_KEYS_DIR}/${keyfilename}" > "${HOST_KEYS_DIR}/${keyfilename}.pub"
    else
        echo "Precreated key ${keyfilename} not found, host key will be generated..."
        ssh-keygen -A
    fi
done

if [ "$COPY_KEYS" ]; then
    cp "${SECRETSDIR}/authorized_keys" "${BASTION_HOMEDIR}/.ssh/authorized_keys"
    chmod u=rw,go=r "${BASTION_HOMEDIR}/.ssh/authorized_keys"
fi

echo "Dockerizing..."
dockerize -template /etc/ssh/sshd_config.gotpl:/etc/ssh/sshd_config

echo "Starting sshd..."
/usr/sbin/sshd -D -e "$@"
