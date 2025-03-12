#!/usr/bin/env bash
set -xe

vault status
sleep 3
echo "Unsealing vault..."
vault operator unseal $(cat vault_init.json | jq -r '.unseal_keys_b64[0]')
vault operator unseal $(cat vault_init.json | jq -r '.unseal_keys_b64[1]')
vault operator unseal $(cat vault_init.json | jq -r '.unseal_keys_b64[2]')
vault status
export VAULT_TOKEN=$(jq -r '.root_token' vault_init.json)
echo
echo "Vault is unsealed and ready to use."
echo VAULT_ADDR: $VAULT_ADDR
echo VAULT_TOKEN: $VAULT_TOKEN
