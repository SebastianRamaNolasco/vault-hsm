# vault with HSM
This repository contains scripts and configurations to set up and manage a HashiCorp Vault instance with HSM (Hardware Security Module) support using SoftHSM and Multipass.

## Prerequisites
- go-task (brew install go-task)
- multipass
- vault

## Setup
Run the task command below to install necessary dependencies and set up the environment.
```shell
task all
```

## Usage
### Set local environment variables
```shell
source .env
```
### Check Vault Status
```shell
vault status
```
### Lookup Vault Token
```shell
vault token lookup
```
### View SoftHSM Slots
```shell
multipass exec vault -- sudo -u vault softhsm2-util --show-slots
```
### View PKCS#11 Module Info

```shell
multipass exec vault -- sudo -u vault pkcs11-tool --module /usr/lib/softhsm/libsofthsm2.so --show-info -v
multipass exec vault -- sudo -u vault pkcs11-tool --module /usr/lib/softhsm/libsofthsm2.so -l -t
```
### Vault PKI Managed Key Configuration
#### Initialize PKI Key
```shell
multipass exec vault -- sudo -u vault softhsm2-util --init-token --free --label "vault_pki_key" --pin 1234 --so-pin 4321
```
#### Restart Vault
```shell
task restart
```
#### Show logs
```shell
task logs
```
#### Configure Vault PKI Managed key
```shell
vault write sys/managed-keys/pkcs11/vault_pki_key  \
      library=vault_pki_key slot=754855359 pin=1234 \
      key_label=vault_pki_key \
      allow_store_key=false \
      allow_generate_key=true \
      mechanism=0x0001 key_bits=4096 \
      any_mount=true

vault secrets enable \
    -allowed-managed-keys=vault_pki_key \
    -default-lease-ttl=24h \
    pki
    
vault read /sys/mounts/pki
```
#### Setup PKI Root CA and Roles
```shell
vault write -field=certificate pki/root/generate/kms \
    managed_key_name=vault_pki_key \
    common_name=root.example.com \
    ttl=8760h

vault write pki/config/urls \
    issuing_certificates="$VAULT_ADDR/v1/pki/ca" \
    crl_distribution_points="$VAULT_ADDR/v1/pki/crl"

vault write pki/roles/example-dot-com \
    allowed_domains=example.com \
    allow_subdomains=true \
    max_ttl=24h
```
#### Issue client certificate
```shell
vault write pki/issue/example-dot-com \
    common_name=www.example.com \
    alt_names=app.example.com
```

#### Useful PKI Commands
```shell
vault list pki/certs
multipass exec vault -- sudo -u vault softhsm2-util --show-slots
vault read -field=certificate /pki/cert/$(vault list -format=json pki/certs | jq -r '.[0]') | openssl x509 -text -noout
vault pki health-check pki
vault read /sys/managed-keys/pkcs11/vault_pki_key
vault read /sys/mounts/pki/tune
```
#### Cleanup 
```shell
task clean
```
