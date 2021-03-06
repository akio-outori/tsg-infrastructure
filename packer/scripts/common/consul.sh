#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

source /var/tmp/helpers/default.sh

readonly CONSUL_FILES='/var/tmp/consul/common'

[[ -d $CONSUL_FILES ]] || mkdir -p "$CONSUL_FILES"

apt_get_update

if ! dpkg -s unzip &> /dev/null; then
    apt-get --assume-yes install \
        unzip
fi

if [[ -z $CONSUL_VERSION ]]; then
    CONSUL_VERSION='1.1.0'
fi

ARCHIVE_FILE="consul_${CONSUL_VERSION}_$(detect_os)_$(detect_platform).zip"

wget -O "${CONSUL_FILES}/${ARCHIVE_FILE}" \
        "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/${ARCHIVE_FILE}"

unzip -q "${CONSUL_FILES}/${ARCHIVE_FILE}" \
      -d "$CONSUL_FILES"

cp -f "${CONSUL_FILES}/consul" \
      /usr/local/bin/consul

chown root: /usr/local/bin/consul
chmod 755 /usr/local/bin/consul

adduser \
    --quiet \
    --system \
    --group \
    --home /nonexistent \
    --no-create-home \
    --disabled-login \
    consul

mkdir -p /etc/consul \
         /etc/consul/conf.d \
         /var/log/consul

chown root: /etc/consul \
            /etc/consul/conf.d

chmod 755 /etc/consul \
          /etc/consul/conf.d

chown consul:adm /var/log/consul
chmod 2750 /var/log/consul

cp -f "${CONSUL_FILES}/consul.default" \
      /etc/default/consul

chown root: /etc/default/consul
chmod 644 /etc/default/consul

cp -f "${CONSUL_FILES}/consul.logrotate" \
      /etc/logrotate.d/consul

chown root: /etc/logrotate.d/consul
chmod 644 /etc/logrotate.d/consul

cat <<'EOF' > /etc/bash_completion.d/consul
complete -C /usr/local/bin/consul consul
EOF

chown root: /etc/bash_completion.d/consul
chmod 644 /etc/bash_completion.d/consul

rm -Rf "$CONSUL_FILES"
