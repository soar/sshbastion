#!/bin/sh -e

HOST_KEY_TYPES="dsa ed25519 ecdsa rsa"
SECRETSDIR=/run/secrets
HOST_KEYS_DIR=/etc/ssh

for host_key_type in "${HOST_KEY_TYPES}"; do
    keyfilename="ssh_host_${host_key_type}_key"

    if [ -r "${SECRETSDIR}/${keyfilename}" ]; then
        echo "Precreated key ${keyfilename} found, will be used as host key..."
        ln -s "${SECRETSDIR}/${keyfilename}" "${HOST_KEYS_DIR}/${keyfilename}"
        ssh-keygen -y -f "${HOST_KEYS_DIR}/${keyfilename}" > "${HOST_KEYS_DIR}/${keyfilename}.pub"
    else
        echo "Precreated key ${keyfilename} not found, host key will be generated..."
        ssh-keygen -A
    fi
done

echo "Starting sshd..."
/usr/sbin/sshd -D -e "$@"
