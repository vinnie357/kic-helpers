# grafana
---
apiVersion: k8s.nginx.org/v1
kind: VirtualServer
metadata:
  name: nsm-grafana
  namespace: nginx-mesh
spec:
  host: grafana.-domain-
  upstreams:
  - name: nsm-grafana
    service: grafana
    port: 3000
  routes:
  - path: /
    action:
      pass: nsm-grafana
---
# prometheus
---
apiVersion: k8s.nginx.org/v1
kind: VirtualServer
metadata:
  name: nsm-prometheus
  namespace: nginx-mesh
spec:
  host: prometheus.-domain-
  upstreams:
  - name: nsm-prometheus
    service: prometheus
    port: 9090
  routes:
  - path: /
    action:
      pass: nsm-prometheus
---
# tracing jaeger
---
apiVersion: k8s.nginx.org/v1
kind: VirtualServer
metadata:
  name: nsm-jaeger
  namespace: nginx-mesh
spec:
  host: jaeger.-domain-
  upstreams:
  - name: nsm-jaeger
    service: jaeger
    port: 16686
  routes:
  - path: /
    action:
      pass: nsm-jaeger
---
