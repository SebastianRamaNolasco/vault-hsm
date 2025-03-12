#!//bin/bash
set -xeo pipefail

export VAULT_ADDR=$1
export VAULT_SKIP_VERIFY=true

echo "VAULT_ADDR: $VAULT_ADDR"
vault status || true
vault operator init -format=json | tee vault_init.json
echo "Waiting for Vault to initialise..."
sleep 10
export VAULT_TOKEN=$(cat vault_init.json | jq -r '.root_token')
vault status
vault audit enable -path="audit_log" file file_path=/var/log/vault/vault_audit.log
echo "Vault initialised, unsealed and audit log enabled"
