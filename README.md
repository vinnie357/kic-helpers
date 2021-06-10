# kic-helpers
helper scripts for building and running Kubernetes Ingress Controllers
---

The examples are meant to deploy an application and service it with one of the ingress controller types.
 - nginx-ingress
 - nginx-plus-ingress
 - nginx-plus-nap

These examples assume you have a running Kubernetes cluster and valid administrative credentials.

The following sample applications are provided:
 - arcadia

## login to your cluster

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
- building and pushing
  ```bash
    build_kic nginx-ingress 1.11.3 registry.domain.com
  ```
- deploying
- examples
### [plus](https://github.com/nginxinc/kubernetes-ingress/blob/master/docs/nginx-plus.md)
- building and pushing
  ```bash
    build_kic nginx-plus-ingress 1.11.3 registry.domain.com
  ```
- deploying
  assumes your KUBECONFIG is set.
  ```bash
    deploy_kic 1.11.3 registry.domain.com
  ```
- examples
    - [NginxPlus Examples Repo](https://github.com/nginxinc/kubernetes-ingress/tree/master/examples)
### plus app protect
- building
  ```bash
    build_kic nginx-plus-ingress-nap 1.11.3 registry.domain.com
  ```
- deploying
- examples

## troubleshooting
### network tools container
```bash
# public
kubectl run multitool --image=praqma/network-multitool
toolPod=$(kubectl get pods -o json | jq -r ".items[].metadata | select(.name | contains (\"multitool\")).name")
kubectl exec -it $toolPod -- sh

# redhat
kubectl run debug-dns --image registry.access.redhat.com/rhel7/rhel-tools -it --rm -- bash

```
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
