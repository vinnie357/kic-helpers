apiVersion: v1
kind: Secret
metadata:
  name: tls-secret
type: kubernetes.io/tls
data:
  tls.crt: -defaultcrt-
  tls.key: -defaultkey-
