#!/bin/bash

set -xe

softhsm2-util --init-token --free  --so-pin=4321 --pin=1234 --label="vault_seal_key"
softhsm2-util --show-slots
chown -R vault:vault /var/lib/softhsm/tokens
VAULT_HSM_SLOT=$(softhsm2-util --show-slots | grep "^Slot " | head -1 | cut -d " " -f 2)
echo $VAULT_HSM_SLOT > /etc/vault.d/vault_seal_slot

mv /tmp/vault.hclic /etc/vault.d/vault.hclic
chown vault:vault /etc/vault.d/vault.hclic
sed -i 's/#license_path.*/license_path = "\/etc\/vault.d\/vault.hclic"/' /etc/vault.d/vault.hcl

cat <<EOF >> /etc/vault.d/vault.hcl

seal "pkcs11" {
  lib            = "/usr/lib/softhsm/libsofthsm2.so"
  slot           = "${VAULT_HSM_SLOT}"
  pin            = "1234"
  key_label      = "vault_seal_key"
  hmac_key_label = "vault_seal_hmac_key"
#  mechanism      = "0x0009"
#  rsa_oaep_hash  = "sha256"
  generate_key   = "true"
}

kms_library "pkcs11" {
    name = "vault_pki_key"
    library = "/usr/lib/softhsm/libsofthsm2.so"
}
EOF

cat /etc/vault.d/vault.hcl
systemctl start vault
sleep 5
journalctl -xeu vault.service --no-pager
