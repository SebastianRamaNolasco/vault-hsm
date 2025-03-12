#!/bin/bash
set -xe

wget -O - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
DEBIAN_FRONTEND=noninteractive apt-get update && apt-get -y upgrade && apt-get install -y curl htop libsofthsm2 opensc softhsm2 unzip vault vim
curl -sLo /tmp/vault.zip  "https://releases.hashicorp.com/vault/$1+ent.hsm/vault_$1+ent.hsm_linux_arm64.zip"
unzip -qo /tmp/vault.zip vault -d /usr/bin/
systemctl enable vault
mkdir /var/log/vault
chown -R vault:vault /var/log/vault
usermod -aG softhsm vault
