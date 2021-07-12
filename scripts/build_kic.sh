function build_kic {
# build_kic [type] [version] [registry] [secret]
# build kic from source
# optional type
# optional secrets
# requires keys and registry
# example:
# build_kic nginx-plus-ingress 1.11.3 registry.domain.com my-secret
type=${1:-"nginx-ingress"}
version=${2:-"1.11.3"}
registry=${3:-"registry.vin-lab.com"}
secretName=${4:-"none"}
dir=${PWD}
# manage secrets
needCerts="nginx-plus-ingress nginx-plus-ingress-nap"
if [ "${secretName}" = "none" ] && [[ " ${needCerts[@]} " =~ " ${type} " ]]; then
  echo "using default secret"
  if [ -f "./certs/nginx-kic-default.crt" ] && [ -f "./certs/nginx-kic-default.key" ]; then
      echo "found default certs"
  else
      # create default cert
      echo "create default kic certs"
      new_cert
  fi
  echo "ingest secrets"
  echo -n "Enter your vault hostname and press [ENTER]: "
  echo ""
  echo -n "default hostname is: http://localhost:8200 :"
  read vaultHost
  echo -n "Enter your vault token and press [ENTER]: "
  echo ""
  echo -n "default token is: root :"
  read -s vaultToken
  echo ""
  echo -n "Enter your secret name and press [ENTER]: "
  read secret
  # store secrets
  #check for devcontainer docker assumes default docker network
  if [[ "${vaultHost}" == "http://localhost:8200" ]]; then
    defaultDocker="127.17.0.1"
    route=$(ip route show default | awk '{ print $3}')
    ip route show default | fgrep -q 'default via 172.17.0.1'
    if [ $? -eq 0 ]; then
      echo "matches docker address $route, $defaultDocker"
      export VAULT_ADDR="http://${route}:8200"
    else
      echo "doesn't match docker $route, $defaultDocker"
      export VAULT_ADDR=${vaultHost}
    fi
    else
      # remote vault
      export VAULT_ADDR=${vaultHost}
  fi
  vault_secrets $vaultHost $vaultToken $secret
  VAULT_TOKEN=${vaultToken:-"root"}
else
  if [[ "${type}" == "nginx-ingress" ]]; then
    echo "oss skipping secrets"
  else
    echo "found secret $secretName"
    echo -n "Enter your vault hostname and press [ENTER]: "
    echo ""
    echo -n "default hostname is: http://localhost:8200 :"
    read vaultHost
    echo -n "Enter your vault token and press [ENTER]: "
    echo ""
    echo -n "default token is: root :"
    read -s vaultToken
    #check for devcontainer docker assumes default docker network
    if [[ "${vaultHost}" == "http://localhost:8200" ]]; then
      defaultDocker="127.17.0.1"
      route=$(ip route show default | awk '{ print $3}')
      ip route show default | fgrep -q 'default via 172.17.0.1'
      if [ $? -eq 0 ]; then
        echo "matches docker address $route, $defaultDocker"
        export VAULT_ADDR="http://${route}:8200"
      else
        echo "doesn't match docker $route, $defaultDocker"
        export VAULT_ADDR=${vaultHost}
      fi
      else
        # remote vault
        export VAULT_ADDR=${vaultHost}
    fi
    VAULT_TOKEN=${vaultToken:-"root"}
  fi
fi
echo "build kic container"
# build kic+image
git clone https://github.com/nginxinc/kubernetes-ingress.git
cd kubernetes-ingress
git checkout tags/v${version}
# get secrets
if [[ "${type}" == "nginx-plus-ingress" ]] || [[ "${type}" == "nginx-plus-ingress-nap" ]]; then
secretData=$(
curl -s \
--header "X-Vault-Token: $VAULT_TOKEN" \
--request GET \
$VAULT_ADDR/v1/secret/data/$secretName
)
echo "writing secrets"
cat << EOF > nginx-repo.crt
$(echo $secretData | jq -r .data.data.nginxCert | base64 -d)
EOF
# key
cat << EOF > nginx-repo.key
$(echo $secretData | jq -r .data.data.nginxKey | base64 -d)
EOF

fi
echo "version: $version type: $type"
if [[ "${type}" == "nginx-ingress" ]]; then
  echo "==== building $type:$version ===="
  ## make nginx-ingress
  make debian-image PREFIX=${registry}/nginx-ingress TARGET=container
  ## push nginx-ingress
  make push PREFIX=${registry}/nginx-ingress
fi

if [[ "${type}" == "nginx-plus-ingress" ]]; then
  echo "==== building $type:$version ===="
  ## make nginx-ingress-plus
  make debian-image-plus PREFIX=${registry}/nginx-plus-ingress TARGET=container
  # remove secrets
  rm nginx-repo.key nginx-repo.crt
  ## push nginx-ingress-plus
  make push PREFIX=${registry}/nginx-plus-ingress
fi

if [[ "${type}" == "nginx-plus-ingress-nap" ]]; then
  echo "==== building $type:$version ===="
  ## make ingress-plus-nap
  make debian-image-nap-plus PREFIX=${registry}/nginx-plus-ingress-nap TARGET=container
  # remove secrets
  rm nginx-repo.key nginx-repo.crt
  ## push nginx-ingress-plus-nap
  make push PREFIX=${registry}/nginx-plus-ingress-nap
fi
# ## v1.10.x
# if [[ "${version}" == "*1.10*" ]]; then
# make DOCKERFILE=DockerfileForPlus VERSION=v${version} PREFIX=${registry}/nginx-plus-ingress
# fi
## all
## v1.10.x
#make DOCKERFILE=DockerfileForPlus VERSION=v${version} PREFIX=${registry}/nginx-plus-ingress
## v1.11.x
# ## make nginx-ingress
# make debian-image PREFIX=${registry}/nginx-ingress TARGET=container
# ## make nginx-ingress-plus
# make debian-image-plus PREFIX=${registry}/nginx-plus-ingress TARGET=container
# ## make ingress-plus-nap
# make debian-image-nap-plus PREFIX=${registry}/nginx-plus-ingress-nap TARGET=container
# ## push nginx-ingress
# make push PREFIX=${registry}/nginx-ingress
# ## push nginx-ingress-plus
# make push PREFIX=${registry}/nginx-plus-ingress
# ## push nginx-ingress-plus-nap
# make push PREFIX=${registry}/nginx-plus-ingress-nap

cd $dir
echo "==== done ===="
}
