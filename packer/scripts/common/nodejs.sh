#!/bin/bash

set -e

export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

source /var/tmp/helpers/default.sh

readonly NODEJS_FILES='/var/tmp/nodejs'

[[ -d $NODEJS_FILES ]] || mkdir -p "$NODEJS_FILES"

apt_get_update

if ! dpkg -s apt-transport-https &> /dev/null; then
    apt-get --assume-yes install \
        apt-transport-https
fi

NODEJS_REPOSITORY='node_8.x'
PACKAGE='nodejs'

if [[ -n $NODEJS_VERSION ]]; then
    NODEJS_REPOSITORY=$(printf 'node_%s.x' "$(echo "$NODEJS_VERSION" | grep -Eo '^[[:digit:]]')")
    PACKAGE=$(printf 'nodejs=%s*' "$NODEJS_VERSION")
fi

if [[ ! -f  "${NODEJS_FILES}/nodesource.key" ]]; then
    wget -O "${NODEJS_FILES}/nodesource.key" \
        https://deb.nodesource.com/gpgkey/nodesource.gpg.key
fi

apt-key add "${NODEJS_FILES}/nodesource.key"

cat <<EOF > /etc/apt/sources.list.d/nodesource.list
deb https://deb.nodesource.com/${NODEJS_REPOSITORY} $(detect_ubuntu_release) main
deb-src https://deb.nodesource.com/${NODEJS_REPOSITORY} $(detect_ubuntu_release) main
EOF

apt-get --assume-yes update \
    -o Dir::Etc::SourceList="/etc/apt/sources.list.d/nodesource.list" \
    -o Dir::Etc::SourceParts='-' -o APT::Get::List-Cleanup='0'

apt-get --assume-yes install "$PACKAGE"

rm -Rf "$NODEJS_FILES"
