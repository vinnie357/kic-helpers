apiVersion: apps/v1
kind: Deployment
metadata:
  name: arcadia-main
spec:
  replicas: 1
  selector:
    matchLabels:
      app: arcadia-main
  template:
    metadata:
      labels:
        app: arcadia-main
    spec:
      containers:
        - name: arcadia-main
          image: sorinboia/arcadia-main:unit
          imagePullPolicy: Always
          ports:
          - containerPort: 8080

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: arcadia-backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: arcadia-backend

  template:
    metadata:
      labels:
        app: arcadia-backend
    spec:
      containers:
        - name: arcadia-backend
          image: sorinboia/arcadia-backend:unit
          imagePullPolicy: Always
          ports:
          - containerPort: 8080

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: arcadia-app2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: arcadia-app2

  template:
    metadata:
      labels:
        app: arcadia-app2
    spec:
      containers:
        - name: arcadia-app2
          image: sorinboia/arcadia-app2:unit
          imagePullPolicy: Always
          ports:
          - containerPort: 8080

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: arcadia-app3
spec:
  replicas: 1
  selector:
    matchLabels:
      app: arcadia-app3

  template:
    metadata:
      labels:
        app: arcadia-app3
    spec:
      containers:
        - name: arcadia-app3
          image: sorinboia/arcadia-app3:unit
          imagePullPolicy: Always
          ports:
          - containerPort: 8080

---

apiVersion: v1
kind: Service
metadata:
  name: arcadia-main
spec:
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
    name: http
  selector:
    app: arcadia-main

---

apiVersion: v1
kind: Service
metadata:
  name: backend
  labels:
    app: arcadia-backend
spec:
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
  selector:
    app: arcadia-backend

---

apiVersion: v1
kind: Service
metadata:
  name: arcadia-app2
  labels:
    app: arcadia-app2
spec:
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
  selector:
    app: arcadia-app2

---

apiVersion: v1
kind: Service
metadata:
  name: arcadia-app3
  labels:
    app: arcadia-app3
spec:
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
  selector:
    app: arcadia-app3
