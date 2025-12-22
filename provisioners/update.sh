#!/bin/bash
set -euxo pipefail

# configure apt for non-interactive mode.
export DEBIAN_FRONTEND=noninteractive

# switch to the non-enterprise repository.
# see https://pve.proxmox.com/wiki/Package_Repositories
dpkg-divert --divert /etc/apt/sources.list.d/pve-enterprise.sources.distrib.disabled --rename --add /etc/apt/sources.list.d/pve-enterprise.sources
dpkg-divert --divert /etc/apt/sources.list.d/ceph.sources.distrib.disabled --rename --add /etc/apt/sources.list.d/ceph.sources
cat >/etc/apt/sources.list.d/pve.sources <<EOF
Types: deb
URIs: http://download.proxmox.com/debian/pve
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: pve-no-subscription
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg
EOF
cat >/etc/apt/sources.list.d/ceph.sources <<EOF
Types: deb
URIs: http://download.proxmox.com/debian/ceph-squid
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: no-subscription
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg
EOF

# switch the apt mirror to adfinis
sed -i -E 's,deb\.debian\.org,pkg.adfinis-on-exoscale.ch,' /etc/apt/sources.list.d/debian.sources

# update only (no upgrade since we want to use this image to test automated cluster upgrades)
apt-get update
apt-get dist-upgrade -y
