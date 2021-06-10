# pihole

assumes you have already deployed kic to your cluster

#https://github.com/MoJo2600/pihole-kubernetes

 requires [helm](https://helm.sh/)
  ```bash
  curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash -
  ```

## add chart
```bash
helm repo add mojo2600 https://mojo2600.github.io/pihole-kubernetes/
helm repo update
```

## deploy a release (random pet)

```bash
myrelease="wacky-cow"
helm install $myrelease mojo2600/pihole

```

## deploy a ingress for nginx

```bash
myfqdn="pihole.vin-lab.com"
myPort="80"
myrelease="wacky-mole"
cat << EOF | kubectl apply -f -
apiVersion: k8s.nginx.org/v1
kind: VirtualServer
metadata:
  name: pihole
spec:
  host: ${myfqdn}
  upstreams:
  - name: pihole-web
    service: ${myrelease}-pihole-web
    port: 80
  routes:
  - path: /
    action:
      pass: pihole-web
EOF
#https://docs.nginx.com/nginx-ingress-controller/configuration/transportserver-resource/
# global listners
#https://docs.nginx.com/nginx-ingress-controller/configuration/global-configuration/globalconfiguration-resource/
cat << EOF | kubectl apply -f -
apiVersion: k8s.nginx.org/v1alpha1
kind: GlobalConfiguration
metadata:
  name: nginx-configuration
  namespace: nginx-ingress
spec:
  listeners:
  - name: pihole-dns-udp
    port: 53
    protocol: UDP
  - name: pihole-dns-tcp
    port: 53
    protocol: TCP
EOF
# tcp transport server
cat << EOF | kubectl apply -f -
apiVersion: k8s.nginx.org/v1alpha1
kind: TransportServer
metadata:
  name: pihole-dns-tcp
spec:
  listener:
    name: pihole-dns-tcp
    protocol: TCP
  upstreams:
  - name: pihole-dns-tcp
    service: ${myrelease}-pihole-dns-tcp
    port: 53
  action:
    pass: pihole-dns-tcp
EOF
# udp transport server
cat << EOF | kubectl apply -f -
apiVersion: k8s.nginx.org/v1alpha1
kind: TransportServer
metadata:
  name: pihole-dns-udp
spec:
  listener:
    name: pihole-dns-udp
    protocol: UDP
  upstreams:
  - name: pihole-dns-udp
    service: ${myrelease}-pihole-dns-udp
    port: 53
  upstreamParameters:
    udpRequests: 1
    udpResponses: 1
  action:
    pass: pihole-dns-udp
EOF

```

```bash
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: nginx-ingress
  namespace: nginx-ingress
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "tcp"
    service.beta.kubernetes.io/aws-load-balancer-proxy-protocol: "*"
spec:
  type: NodePort
  ports:
    - port: 80
      targetPort: 80
      protocol: TCP
      name: http
    - port: 443
      targetPort: 443
      protocol: TCP
      name: https
    - port: 53
      targetPort: 53
      protocol: TCP
      name: dns-tcp
    - port: 53
      targetPort: 53
      protocol: UDP
      name: dns-udp
  selector:
    app: nginx-ingress
EOF
```
