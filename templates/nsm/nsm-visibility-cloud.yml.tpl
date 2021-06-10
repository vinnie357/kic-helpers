#https://docs.nginx.com/nginx-service-mesh/tutorials/deploy-example-app/
# grafana
---
apiVersion: v1
kind: Service
metadata:
  name: grafana-nginx-mesh
  namespace: nginx-mesh
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 3000
    protocol: TCP
    name: http
  selector:
    app.kubernetes.io/name: grafana
---
# Prometheus
---
apiVersion: v1
kind: Service
metadata:
  name: prometheus-nginx-mesh
  namespace: nginx-mesh
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 9090
    protocol: TCP
    name: http
  selector:
    app.kubernetes.io/name: prometheus
---
# tracing jaeger
---
apiVersion: v1
kind: Service
metadata:
  name: tracing-nginx-mesh
  namespace: nginx-mesh
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 16686
    protocol: TCP
    name: http
  selector:
    app.kubernetes.io/name: jaeger
---
