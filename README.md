# kic-helpers
helper scripts for building and running Kubernetes Ingress Controllers
---


## login

```bash
export KUBECONFIG=$HOME/.kube/myconfig
```
## Initialize helper scripts

```bash
. init.sh
```

## secrets
example local vault container requires docker

```bash
cd vault-dev
make vault && make test
```

## certs
get a new self signed cert for default ingress

```bash
. init.sh && new_cert
```
## nginx

### open source
- building
- pushing
- deploying
- examples
### plus
- building
- pushing
- deploying
- examples
### plus app protect
- building
- pushing
- deploying
- examples

## troubleshooting

### stuck namespace
delete finalizers
```bash
NAMESPACE=my-namespace
# check for resources
kubectl -n $NAMESPACE get all
# remove finalizers
kubectl proxy &
kubectl get namespace $NAMESPACE -o json |jq '.spec = {"finalizers":[]}' >temp.json
curl -k -H "Content-Type: application/json" -X PUT --data-binary @temp.json 127.0.0.1:8001/api/v1/namespaces/$NAMESPACE/finalize
```

## devcontainer

includes:
- pre-commit
- go
- docker
- terraform
- terraform-docs
## Development

don't forget to add your git user config

```bash
git config --global user.name "myuser"
git config --global user.email "myuser@domain.com"
```
---

checking for secrets as well as linting is performed by git pre-commit with the module requirements handled in the devcontainer.

testing pre-commit hooks:
  ```bash
  # test pre commit manually
  pre-commit run -a -v
  ```
---
