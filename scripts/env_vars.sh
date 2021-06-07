function env_vars {
#!/bin/bash
# requires jq
# assumes secrets vault kv2 api and your vault is unsealed
## set vars
# vault
echo -n "Enter your vault hostname and press [ENTER]: "
read vaultHost
echo -n "Enter your vault token and press [ENTER]: "
read -s vaultToken
echo ""
echo -n "Enter your bigip username and press [ENTER]: "
read BIGIP_ADMIN
echo -n "Enter your bigip password and press [ENTER]: "
read -s BIGIP_PASS
echo ""
echo -n "Enter your ssh key name and press [ENTER]: "
read ssh_key_name
echo -n "Enter file path to your gcp creds file and press [ENTER]"
echo -n "example: ~/mycreds.json"
echo ""
read GCP_CREDS_FILE_PATH
export VAULT_ADDR=${vaultHost}
export VAULT_TOKEN=$(echo "${vaultToken}")

#vaultHost='http://vault.mydomain.com'
# ssh key
# linux
ssh_key_dir="$(echo $HOME)/.ssh"
# windows wsl
#ssh_key_dir="/c/Users/myuser/.ssh"
export SSH_KEY_DIR=${ssh_key_dir}
export SSH_KEY_NAME=${ssh_key_name}
bigip=$(cat -<<EOF
{
  "data": {
      "admin": "${BIGIP_ADMIN}",
      "pass": "${BIGIP_PASS}"
    }
}
EOF
)
PUBLIC_KEY=$(cat ~/.ssh/${ssh_key_name}.pub)
pubKey=$(cat -<<EOF
{
  "data": {
      "key": "${PUBLIC_KEY}"
    }
}
EOF
)
gcpCredsFile=$(cat -<<EOF
{
  "data": $(cat $GCP_CREDS_FILE_PATH)
}
EOF
)
# Normal servers have version 1 of KV mounted by default, so will need these
# paths:
# path "secret/*" {
#   capabilities = ["create", "update"]
# }
# path "secret/foo" {
#   capabilities = ["read"]
# }

# # Dev servers have version 2 of KV mounted by default, so will need these
# # paths:
# path "secret/data/*" {
#   capabilities = ["create", "update"]
# }
# path "secret/data/foo" {
#   capabilities = ["read"]
# }
function kvVersion () {
    curl -s \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request GET \
    $vaultHost/v1/sys/mounts | jq keys | grep 'secret/' > /dev/null 2>&1
    if [ $? == 0 ]; then
        version=$(curl -s --header "X-Vault-Token: $VAULT_TOKEN" --request GET $vaultHost/v1/sys/mounts | jq -r '.["secret/"].options.version')
        echo $version
    else
        echo "type yes to enable the v2 secrets api"
        read answer
        if [ $answer == "yes" ]; then
            curl --header "X-Vault-Token: $VAULT_TOKEN" \
            --request POST \
            --data '{ "type": "kv-v2" }' \
            $vaultHost/v1/sys/mounts/secret
            echo "v2 enabled at /secret"
        else
            echo "please enable v2 to continue"
        fi
    fi

}
# vault store data
# bigip
kvApiVersion=$(kvVersion)
echo "kv version: $kvApiVersion"
if [ $kvApiVersion == "2" ]; then
    curl  \
        --header "X-Vault-Token: $VAULT_TOKEN" \
        --request POST \
        --data "$bigip" \
        $vaultHost/v1/secret/data/bigip
    curl  \
        --header "X-Vault-Token: $VAULT_TOKEN" \
        --request POST \
        --data "$pubKey" \
        $vaultHost/v1/secret/data/gcp_pub_key
    curl  \
        --header "X-Vault-Token: $VAULT_TOKEN" \
        --request POST \
        --data "$gcpCredsFile" \
        $vaultHost/v1/secret/data/gcp_creds_file
else
    echo "kv api version not v2"
    echo "quitting..."
fi
#
# GCP
function gcpApi () {
    curl -s \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request GET \
    $vaultHost/v1/sys/mounts | jq keys | grep 'gcp/' > /dev/null 2>&1
    if [ $? == 0 ]; then
        apiType=$(curl -s --header "X-Vault-Token: $VAULT_TOKEN" --request GET $vaultHost/v1/sys/mounts | jq -r '.["gcp/"].type')
        echo $apiType
    else
        echo "type yes to enable the gcp secrets api"
        read answer
        if [ $answer == "yes" ]; then
            curl --header "X-Vault-Token: $VAULT_TOKEN" \
            --request POST \
            --data '{ "type": "gcp" }' \
            $vaultHost/v1/sys/mounts/gcp
            echo "gcp enabled at /gcp"
        else
            echo "please enable gcp to continue"
        fi
    fi

}
gcpApi
GCP_CREDS=$(cat $GCP_CREDS_FILE_PATH | jq tostring)
gcpCredsPayload=$(cat -<<EOF
{
  "data": {
        "credentials": $GCP_CREDS,
        "ttl": 3600,
        "max_ttl": 14400
    }
}
EOF
)

# create gcp config
curl  \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data "$gcpCredsPayload" \
    $vaultHost/v1/gcp/config
curl  \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request GET \
    $vaultHost/v1/gcp/config
# create gcp role

#
# read/check vault data
#
# curl -s \
# --header "X-Vault-Token: $VAULT_TOKEN" \
# --request GET \
#  $vaultHost/v1/secret/data/bigip

# curl -s \
# --header "X-Vault-Token: $VAULT_TOKEN" \
# --request GET \
#  $vaultHost/v1/secret/data/gcp_pub_key
echo "env vars done"
}
