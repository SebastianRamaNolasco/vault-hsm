#!/usr/bin/env bash
set -o pipefail

vault status
echo
echo export VAULT_ADDR=$VAULT_ADDR
echo export VAULT_TOKEN=$VAULT_TOKEN

if [[ "$OSTYPE" =~ ^darwin ]]; then
  echo $VAULT_TOKEN | pbcopy
  echo "Vault token copied to clipboard"
fi
