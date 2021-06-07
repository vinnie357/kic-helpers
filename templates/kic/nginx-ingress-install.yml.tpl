apiVersion: v1
kind: Namespace
metadata:
  name: nginx-ingress
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: nginx-ingress
  namespace: nginx-ingress

---

kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: nginx-ingress
rules:
- apiGroups:
  - ""
  resources:
  - services
  - endpoints
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - secrets
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - configmaps
  verbs:
  - get
  - list
  - watch
  - update
  - create
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - events
  verbs:
  - create
  - patch
  - list
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses
  verbs:
  - list
  - watch
  - get
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses/status
  verbs:
  - update
- apiGroups:
  - k8s.nginx.org
  resources:
  - virtualservers
  - virtualserverroutes
  - globalconfigurations
  - transportservers
  - policies
  verbs:
  - list
  - watch
  - get
- apiGroups:
  - k8s.nginx.org
  resources:
  - virtualservers/status
  - virtualserverroutes/status
  - policies/status
  verbs:
  - update
- apiGroups:
  - networking.k8s.io
  resources:
  - ingressclasses
  verbs:
  - get
- apiGroups:
    - cis.f5.com
  resources:
    - ingresslinks
  verbs:
    - list
    - watch
    - get
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: nginx-ingress
subjects:
- kind: ServiceAccount
  name: nginx-ingress
  namespace: nginx-ingress
roleRef:
  kind: ClusterRole
  name: nginx-ingress
  apiGroup: rbac.authorization.k8s.io

---

apiVersion: v1
kind: Secret
metadata:
  name: default-server-secret
  namespace: nginx-ingress
type: kubernetes.io/tls
data:
  tls.crt: -defaultCert-
  tls.key: -defaultKey-

---

 kind: ConfigMap
 apiVersion: v1
 metadata:
   name: nginx-config
   namespace: nginx-ingress
 data:
   proxy-protocol: "False"
   real-ip-header: "proxy_protocol"
   set-real-ip-from: "0.0.0.0/0"

---

apiVersion: networking.k8s.io/v1beta1
kind: IngressClass
metadata:
  name: nginx
  # annotations:
  #   ingressclass.kubernetes.io/is-default-class: "true"
spec:
  controller: nginx.org/ingress-controller

---

apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    controller-gen.kubebuilder.io/version: v0.4.1
  creationTimestamp: null
  name: virtualservers.k8s.nginx.org
spec:
  group: k8s.nginx.org
  names:
    kind: VirtualServer
    listKind: VirtualServerList
    plural: virtualservers
    shortNames:
      - vs
    singular: virtualserver
  scope: Namespaced
  versions:
    - additionalPrinterColumns:
        - description: Current state of the VirtualServer. If the resource has a valid status, it means it has been validated and accepted by the Ingress Controller.
          jsonPath: .status.state
          name: State
          type: string
        - jsonPath: .spec.host
          name: Host
          type: string
        - jsonPath: .status.externalEndpoints[*].ip
          name: IP
          type: string
        - jsonPath: .status.externalEndpoints[*].ports
          name: Ports
          type: string
        - jsonPath: .metadata.creationTimestamp
          name: Age
          type: date
      name: v1
      schema:
        openAPIV3Schema:
          description: VirtualServer defines the VirtualServer resource.
          type: object
          properties:
            apiVersion:
              description: 'APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources'
              type: string
            kind:
              description: 'Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds'
              type: string
            metadata:
              type: object
            spec:
              description: VirtualServerSpec is the spec of the VirtualServer resource.
              type: object
              properties:
                host:
                  type: string
                http-snippets:
                  type: string
                ingressClassName:
                  type: string
                policies:
                  type: array
                  items:
                    description: PolicyReference references a policy by name and an optional namespace.
                    type: object
                    properties:
                      name:
                        type: string
                      namespace:
                        type: string
                routes:
                  type: array
                  items:
                    description: Route defines a route.
                    type: object
                    properties:
                      action:
                        description: Action defines an action.
                        type: object
                        properties:
                          pass:
                            type: string
                          proxy:
                            description: ActionProxy defines a proxy in an Action.
                            type: object
                            properties:
                              requestHeaders:
                                description: ProxyRequestHeaders defines the request headers manipulation in an ActionProxy.
                                type: object
                                properties:
                                  pass:
                                    type: boolean
                                  set:
                                    type: array
                                    items:
                                      description: Header defines an HTTP Header.
                                      type: object
                                      properties:
                                        name:
                                          type: string
                                        value:
                                          type: string
                              responseHeaders:
                                description: ProxyResponseHeaders defines the response headers manipulation in an ActionProxy.
                                type: object
                                properties:
                                  add:
                                    type: array
                                    items:
                                      description: AddHeader defines an HTTP Header with an optional Always field to use with the add_header NGINX directive.
                                      type: object
                                      properties:
                                        always:
                                          type: boolean
                                        name:
                                          type: string
                                        value:
                                          type: string
                                  hide:
                                    type: array
                                    items:
                                      type: string
                                  ignore:
                                    type: array
                                    items:
                                      type: string
                                  pass:
                                    type: array
                                    items:
                                      type: string
                              rewritePath:
                                type: string
                              upstream:
                                type: string
                          redirect:
                            description: ActionRedirect defines a redirect in an Action.
                            type: object
                            properties:
                              code:
                                type: integer
                              url:
                                type: string
                          return:
                            description: ActionReturn defines a return in an Action.
                            type: object
                            properties:
                              body:
                                type: string
                              code:
                                type: integer
                              type:
                                type: string
                      errorPages:
                        type: array
                        items:
                          description: ErrorPage defines an ErrorPage in a Route.
                          type: object
                          properties:
                            codes:
                              type: array
                              items:
                                type: integer
                            redirect:
                              description: ErrorPageRedirect defines a redirect for an ErrorPage.
                              type: object
                              properties:
                                code:
                                  type: integer
                                url:
                                  type: string
                            return:
                              description: ErrorPageReturn defines a return for an ErrorPage.
                              type: object
                              properties:
                                body:
                                  type: string
                                code:
                                  type: integer
                                headers:
                                  type: array
                                  items:
                                    description: Header defines an HTTP Header.
                                    type: object
                                    properties:
                                      name:
                                        type: string
                                      value:
                                        type: string
                                type:
                                  type: string
                      location-snippets:
                        type: string
                      matches:
                        type: array
                        items:
                          description: Match defines a match.
                          type: object
                          properties:
                            action:
                              description: Action defines an action.
                              type: object
                              properties:
                                pass:
                                  type: string
                                proxy:
                                  description: ActionProxy defines a proxy in an Action.
                                  type: object
                                  properties:
                                    requestHeaders:
                                      description: ProxyRequestHeaders defines the request headers manipulation in an ActionProxy.
                                      type: object
                                      properties:
                                        pass:
                                          type: boolean
                                        set:
                                          type: array
                                          items:
                                            description: Header defines an HTTP Header.
                                            type: object
                                            properties:
                                              name:
                                                type: string
                                              value:
                                                type: string
                                    responseHeaders:
                                      description: ProxyResponseHeaders defines the response headers manipulation in an ActionProxy.
                                      type: object
                                      properties:
                                        add:
                                          type: array
                                          items:
                                            description: AddHeader defines an HTTP Header with an optional Always field to use with the add_header NGINX directive.
                                            type: object
                                            properties:
                                              always:
                                                type: boolean
                                              name:
                                                type: string
                                              value:
                                                type: string
                                        hide:
                                          type: array
                                          items:
                                            type: string
                                        ignore:
                                          type: array
                                          items:
                                            type: string
                                        pass:
                                          type: array
                                          items:
                                            type: string
                                    rewritePath:
                                      type: string
                                    upstream:
                                      type: string
                                redirect:
                                  description: ActionRedirect defines a redirect in an Action.
                                  type: object
                                  properties:
                                    code:
                                      type: integer
                                    url:
                                      type: string
                                return:
                                  description: ActionReturn defines a return in an Action.
                                  type: object
                                  properties:
                                    body:
                                      type: string
                                    code:
                                      type: integer
                                    type:
                                      type: string
                            conditions:
                              type: array
                              items:
                                description: Condition defines a condition in a MatchRule.
                                type: object
                                properties:
                                  argument:
                                    type: string
                                  cookie:
                                    type: string
                                  header:
                                    type: string
                                  value:
                                    type: string
                                  variable:
                                    type: string
                            splits:
                              type: array
                              items:
                                description: Split defines a split.
                                type: object
                                properties:
                                  action:
                                    description: Action defines an action.
                                    type: object
                                    properties:
                                      pass:
                                        type: string
                                      proxy:
                                        description: ActionProxy defines a proxy in an Action.
                                        type: object
                                        properties:
                                          requestHeaders:
                                            description: ProxyRequestHeaders defines the request headers manipulation in an ActionProxy.
                                            type: object
                                            properties:
                                              pass:
                                                type: boolean
                                              set:
                                                type: array
                                                items:
                                                  description: Header defines an HTTP Header.
                                                  type: object
                                                  properties:
                                                    name:
                                                      type: string
                                                    value:
                                                      type: string
                                          responseHeaders:
                                            description: ProxyResponseHeaders defines the response headers manipulation in an ActionProxy.
                                            type: object
                                            properties:
                                              add:
                                                type: array
                                                items:
                                                  description: AddHeader defines an HTTP Header with an optional Always field to use with the add_header NGINX directive.
                                                  type: object
                                                  properties:
                                                    always:
                                                      type: boolean
                                                    name:
                                                      type: string
                                                    value:
                                                      type: string
                                              hide:
                                                type: array
                                                items:
                                                  type: string
                                              ignore:
                                                type: array
                                                items:
                                                  type: string
                                              pass:
                                                type: array
                                                items:
                                                  type: string
                                          rewritePath:
                                            type: string
                                          upstream:
                                            type: string
                                      redirect:
                                        description: ActionRedirect defines a redirect in an Action.
                                        type: object
                                        properties:
                                          code:
                                            type: integer
                                          url:
                                            type: string
                                      return:
                                        description: ActionReturn defines a return in an Action.
                                        type: object
                                        properties:
                                          body:
                                            type: string
                                          code:
                                            type: integer
                                          type:
                                            type: string
                                  weight:
                                    type: integer
                      path:
                        type: string
                      policies:
                        type: array
                        items:
                          description: PolicyReference references a policy by name and an optional namespace.
                          type: object
                          properties:
                            name:
                              type: string
                            namespace:
                              type: string
                      route:
                        type: string
                      splits:
                        type: array
                        items:
                          description: Split defines a split.
                          type: object
                          properties:
                            action:
                              description: Action defines an action.
                              type: object
                              properties:
                                pass:
                                  type: string
                                proxy:
                                  description: ActionProxy defines a proxy in an Action.
                                  type: object
                                  properties:
                                    requestHeaders:
                                      description: ProxyRequestHeaders defines the request headers manipulation in an ActionProxy.
                                      type: object
                                      properties:
                                        pass:
                                          type: boolean
                                        set:
                                          type: array
                                          items:
                                            description: Header defines an HTTP Header.
                                            type: object
                                            properties:
                                              name:
                                                type: string
                                              value:
                                                type: string
                                    responseHeaders:
                                      description: ProxyResponseHeaders defines the response headers manipulation in an ActionProxy.
                                      type: object
                                      properties:
                                        add:
                                          type: array
                                          items:
                                            description: AddHeader defines an HTTP Header with an optional Always field to use with the add_header NGINX directive.
                                            type: object
                                            properties:
                                              always:
                                                type: boolean
                                              name:
                                                type: string
                                              value:
                                                type: string
                                        hide:
                                          type: array
                                          items:
                                            type: string
                                        ignore:
                                          type: array
                                          items:
                                            type: string
                                        pass:
                                          type: array
                                          items:
                                            type: string
                                    rewritePath:
                                      type: string
                                    upstream:
                                      type: string
                                redirect:
                                  description: ActionRedirect defines a redirect in an Action.
                                  type: object
                                  properties:
                                    code:
                                      type: integer
                                    url:
                                      type: string
                                return:
                                  description: ActionReturn defines a return in an Action.
                                  type: object
                                  properties:
                                    body:
                                      type: string
                                    code:
                                      type: integer
                                    type:
                                      type: string
                            weight:
                              type: integer
                server-snippets:
                  type: string
                tls:
                  description: TLS defines TLS configuration for a VirtualServer.
                  type: object
                  properties:
                    redirect:
                      description: TLSRedirect defines a redirect for a TLS.
                      type: object
                      properties:
                        basedOn:
                          type: string
                        code:
                          type: integer
                        enable:
                          type: boolean
                    secret:
                      type: string
                upstreams:
                  type: array
                  items:
                    description: Upstream defines an upstream.
                    type: object
                    properties:
                      buffer-size:
                        type: string
                      buffering:
                        type: boolean
                      buffers:
                        description: UpstreamBuffers defines Buffer Configuration for an Upstream.
                        type: object
                        properties:
                          number:
                            type: integer
                          size:
                            type: string
                      client-max-body-size:
                        type: string
                      connect-timeout:
                        type: string
                      fail-timeout:
                        type: string
                      healthCheck:
                        description: HealthCheck defines the parameters for active Upstream HealthChecks.
                        type: object
                        properties:
                          connect-timeout:
                            type: string
                          enable:
                            type: boolean
                          fails:
                            type: integer
                          headers:
                            type: array
                            items:
                              description: Header defines an HTTP Header.
                              type: object
                              properties:
                                name:
                                  type: string
                                value:
                                  type: string
                          interval:
                            type: string
                          jitter:
                            type: string
                          passes:
                            type: integer
                          path:
                            type: string
                          port:
                            type: integer
                          read-timeout:
                            type: string
                          send-timeout:
                            type: string
                          statusMatch:
                            type: string
                          tls:
                            description: UpstreamTLS defines a TLS configuration for an Upstream.
                            type: object
                            properties:
                              enable:
                                type: boolean
                      keepalive:
                        type: integer
                      lb-method:
                        type: string
                      max-conns:
                        type: integer
                      max-fails:
                        type: integer
                      name:
                        type: string
                      next-upstream:
                        type: string
                      next-upstream-timeout:
                        type: string
                      next-upstream-tries:
                        type: integer
                      port:
                        type: integer
                      queue:
                        description: UpstreamQueue defines Queue Configuration for an Upstream.
                        type: object
                        properties:
                          size:
                            type: integer
                          timeout:
                            type: string
                      read-timeout:
                        type: string
                      send-timeout:
                        type: string
                      service:
                        type: string
                      sessionCookie:
                        description: SessionCookie defines the parameters for session persistence.
                        type: object
                        properties:
                          domain:
                            type: string
                          enable:
                            type: boolean
                          expires:
                            type: string
                          httpOnly:
                            type: boolean
                          name:
                            type: string
                          path:
                            type: string
                          secure:
                            type: boolean
                      slow-start:
                        type: string
                      subselector:
                        type: object
                        additionalProperties:
                          type: string
                      tls:
                        description: UpstreamTLS defines a TLS configuration for an Upstream.
                        type: object
                        properties:
                          enable:
                            type: boolean
            status:
              description: VirtualServerStatus defines the status for the VirtualServer resource.
              type: object
              properties:
                externalEndpoints:
                  type: array
                  items:
                    description: ExternalEndpoint defines the IP and ports used to connect to this resource.
                    type: object
                    properties:
                      ip:
                        type: string
                      ports:
                        type: string
                message:
                  type: string
                reason:
                  type: string
                state:
                  type: string
      served: true
      storage: true
      subresources:
        status: {}
status:
  acceptedNames:
    kind: ""
    plural: ""
  conditions: []
  storedVersions: []

---

apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    controller-gen.kubebuilder.io/version: v0.4.1
  creationTimestamp: null
  name: virtualserverroutes.k8s.nginx.org
spec:
  group: k8s.nginx.org
  names:
    kind: VirtualServerRoute
    listKind: VirtualServerRouteList
    plural: virtualserverroutes
    shortNames:
      - vsr
    singular: virtualserverroute
  scope: Namespaced
  versions:
    - additionalPrinterColumns:
        - description: Current state of the VirtualServerRoute. If the resource has a valid status, it means it has been validated and accepted by the Ingress Controller.
          jsonPath: .status.state
          name: State
          type: string
        - jsonPath: .spec.host
          name: Host
          type: string
        - jsonPath: .status.externalEndpoints[*].ip
          name: IP
          type: string
        - jsonPath: .status.externalEndpoints[*].ports
          name: Ports
          type: string
        - jsonPath: .metadata.creationTimestamp
          name: Age
          type: date
      name: v1
      schema:
        openAPIV3Schema:
          description: VirtualServerRoute defines the VirtualServerRoute resource.
          type: object
          properties:
            apiVersion:
              description: 'APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources'
              type: string
            kind:
              description: 'Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds'
              type: string
            metadata:
              type: object
            spec:
              description: VirtualServerRouteSpec is the spec of the VirtualServerRoute resource.
              type: object
              properties:
                host:
                  type: string
                ingressClassName:
                  type: string
                subroutes:
                  type: array
                  items:
                    description: Route defines a route.
                    type: object
                    properties:
                      action:
                        description: Action defines an action.
                        type: object
                        properties:
                          pass:
                            type: string
                          proxy:
                            description: ActionProxy defines a proxy in an Action.
                            type: object
                            properties:
                              requestHeaders:
                                description: ProxyRequestHeaders defines the request headers manipulation in an ActionProxy.
                                type: object
                                properties:
                                  pass:
                                    type: boolean
                                  set:
                                    type: array
                                    items:
                                      description: Header defines an HTTP Header.
                                      type: object
                                      properties:
                                        name:
                                          type: string
                                        value:
                                          type: string
                              responseHeaders:
                                description: ProxyResponseHeaders defines the response headers manipulation in an ActionProxy.
                                type: object
                                properties:
                                  add:
                                    type: array
                                    items:
                                      description: AddHeader defines an HTTP Header with an optional Always field to use with the add_header NGINX directive.
                                      type: object
                                      properties:
                                        always:
                                          type: boolean
                                        name:
                                          type: string
                                        value:
                                          type: string
                                  hide:
                                    type: array
                                    items:
                                      type: string
                                  ignore:
                                    type: array
                                    items:
                                      type: string
                                  pass:
                                    type: array
                                    items:
                                      type: string
                              rewritePath:
                                type: string
                              upstream:
                                type: string
                          redirect:
                            description: ActionRedirect defines a redirect in an Action.
                            type: object
                            properties:
                              code:
                                type: integer
                              url:
                                type: string
                          return:
                            description: ActionReturn defines a return in an Action.
                            type: object
                            properties:
                              body:
                                type: string
                              code:
                                type: integer
                              type:
                                type: string
                      errorPages:
                        type: array
                        items:
                          description: ErrorPage defines an ErrorPage in a Route.
                          type: object
                          properties:
                            codes:
                              type: array
                              items:
                                type: integer
                            redirect:
                              description: ErrorPageRedirect defines a redirect for an ErrorPage.
                              type: object
                              properties:
                                code:
                                  type: integer
                                url:
                                  type: string
                            return:
                              description: ErrorPageReturn defines a return for an ErrorPage.
                              type: object
                              properties:
                                body:
                                  type: string
                                code:
                                  type: integer
                                headers:
                                  type: array
                                  items:
                                    description: Header defines an HTTP Header.
                                    type: object
                                    properties:
                                      name:
                                        type: string
                                      value:
                                        type: string
                                type:
                                  type: string
                      location-snippets:
                        type: string
                      matches:
                        type: array
                        items:
                          description: Match defines a match.
                          type: object
                          properties:
                            action:
                              description: Action defines an action.
                              type: object
                              properties:
                                pass:
                                  type: string
                                proxy:
                                  description: ActionProxy defines a proxy in an Action.
                                  type: object
                                  properties:
                                    requestHeaders:
                                      description: ProxyRequestHeaders defines the request headers manipulation in an ActionProxy.
                                      type: object
                                      properties:
                                        pass:
                                          type: boolean
                                        set:
                                          type: array
                                          items:
                                            description: Header defines an HTTP Header.
                                            type: object
                                            properties:
                                              name:
                                                type: string
                                              value:
                                                type: string
                                    responseHeaders:
                                      description: ProxyResponseHeaders defines the response headers manipulation in an ActionProxy.
                                      type: object
                                      properties:
                                        add:
                                          type: array
                                          items:
                                            description: AddHeader defines an HTTP Header with an optional Always field to use with the add_header NGINX directive.
                                            type: object
                                            properties:
                                              always:
                                                type: boolean
                                              name:
                                                type: string
                                              value:
                                                type: string
                                        hide:
                                          type: array
                                          items:
                                            type: string
                                        ignore:
                                          type: array
                                          items:
                                            type: string
                                        pass:
                                          type: array
                                          items:
                                            type: string
                                    rewritePath:
                                      type: string
                                    upstream:
                                      type: string
                                redirect:
                                  description: ActionRedirect defines a redirect in an Action.
                                  type: object
                                  properties:
                                    code:
                                      type: integer
                                    url:
                                      type: string
                                return:
                                  description: ActionReturn defines a return in an Action.
                                  type: object
                                  properties:
                                    body:
                                      type: string
                                    code:
                                      type: integer
                                    type:
                                      type: string
                            conditions:
                              type: array
                              items:
                                description: Condition defines a condition in a MatchRule.
                                type: object
                                properties:
                                  argument:
                                    type: string
                                  cookie:
                                    type: string
                                  header:
                                    type: string
                                  value:
                                    type: string
                                  variable:
                                    type: string
                            splits:
                              type: array
                              items:
                                description: Split defines a split.
                                type: object
                                properties:
                                  action:
                                    description: Action defines an action.
                                    type: object
                                    properties:
                                      pass:
                                        type: string
                                      proxy:
                                        description: ActionProxy defines a proxy in an Action.
                                        type: object
                                        properties:
                                          requestHeaders:
                                            description: ProxyRequestHeaders defines the request headers manipulation in an ActionProxy.
                                            type: object
                                            properties:
                                              pass:
                                                type: boolean
                                              set:
                                                type: array
                                                items:
                                                  description: Header defines an HTTP Header.
                                                  type: object
                                                  properties:
                                                    name:
                                                      type: string
                                                    value:
                                                      type: string
                                          responseHeaders:
                                            description: ProxyResponseHeaders defines the response headers manipulation in an ActionProxy.
                                            type: object
                                            properties:
                                              add:
                                                type: array
                                                items:
                                                  description: AddHeader defines an HTTP Header with an optional Always field to use with the add_header NGINX directive.
                                                  type: object
                                                  properties:
                                                    always:
                                                      type: boolean
                                                    name:
                                                      type: string
                                                    value:
                                                      type: string
                                              hide:
                                                type: array
                                                items:
                                                  type: string
                                              ignore:
                                                type: array
                                                items:
                                                  type: string
                                              pass:
                                                type: array
                                                items:
                                                  type: string
                                          rewritePath:
                                            type: string
                                          upstream:
                                            type: string
                                      redirect:
                                        description: ActionRedirect defines a redirect in an Action.
                                        type: object
                                        properties:
                                          code:
                                            type: integer
                                          url:
                                            type: string
                                      return:
                                        description: ActionReturn defines a return in an Action.
                                        type: object
                                        properties:
                                          body:
                                            type: string
                                          code:
                                            type: integer
                                          type:
                                            type: string
                                  weight:
                                    type: integer
                      path:
                        type: string
                      policies:
                        type: array
                        items:
                          description: PolicyReference references a policy by name and an optional namespace.
                          type: object
                          properties:
                            name:
                              type: string
                            namespace:
                              type: string
                      route:
                        type: string
                      splits:
                        type: array
                        items:
                          description: Split defines a split.
                          type: object
                          properties:
                            action:
                              description: Action defines an action.
                              type: object
                              properties:
                                pass:
                                  type: string
                                proxy:
                                  description: ActionProxy defines a proxy in an Action.
                                  type: object
                                  properties:
                                    requestHeaders:
                                      description: ProxyRequestHeaders defines the request headers manipulation in an ActionProxy.
                                      type: object
                                      properties:
                                        pass:
                                          type: boolean
                                        set:
                                          type: array
                                          items:
                                            description: Header defines an HTTP Header.
                                            type: object
                                            properties:
                                              name:
                                                type: string
                                              value:
                                                type: string
                                    responseHeaders:
                                      description: ProxyResponseHeaders defines the response headers manipulation in an ActionProxy.
                                      type: object
                                      properties:
                                        add:
                                          type: array
                                          items:
                                            description: AddHeader defines an HTTP Header with an optional Always field to use with the add_header NGINX directive.
                                            type: object
                                            properties:
                                              always:
                                                type: boolean
                                              name:
                                                type: string
                                              value:
                                                type: string
                                        hide:
                                          type: array
                                          items:
                                            type: string
                                        ignore:
                                          type: array
                                          items:
                                            type: string
                                        pass:
                                          type: array
                                          items:
                                            type: string
                                    rewritePath:
                                      type: string
                                    upstream:
                                      type: string
                                redirect:
                                  description: ActionRedirect defines a redirect in an Action.
                                  type: object
                                  properties:
                                    code:
                                      type: integer
                                    url:
                                      type: string
                                return:
                                  description: ActionReturn defines a return in an Action.
                                  type: object
                                  properties:
                                    body:
                                      type: string
                                    code:
                                      type: integer
                                    type:
                                      type: string
                            weight:
                              type: integer
                upstreams:
                  type: array
                  items:
                    description: Upstream defines an upstream.
                    type: object
                    properties:
                      buffer-size:
                        type: string
                      buffering:
                        type: boolean
                      buffers:
                        description: UpstreamBuffers defines Buffer Configuration for an Upstream.
                        type: object
                        properties:
                          number:
                            type: integer
                          size:
                            type: string
                      client-max-body-size:
                        type: string
                      connect-timeout:
                        type: string
                      fail-timeout:
                        type: string
                      healthCheck:
                        description: HealthCheck defines the parameters for active Upstream HealthChecks.
                        type: object
                        properties:
                          connect-timeout:
                            type: string
                          enable:
                            type: boolean
                          fails:
                            type: integer
                          headers:
                            type: array
                            items:
                              description: Header defines an HTTP Header.
                              type: object
                              properties:
                                name:
                                  type: string
                                value:
                                  type: string
                          interval:
                            type: string
                          jitter:
                            type: string
                          passes:
                            type: integer
                          path:
                            type: string
                          port:
                            type: integer
                          read-timeout:
                            type: string
                          send-timeout:
                            type: string
                          statusMatch:
                            type: string
                          tls:
                            description: UpstreamTLS defines a TLS configuration for an Upstream.
                            type: object
                            properties:
                              enable:
                                type: boolean
                      keepalive:
                        type: integer
                      lb-method:
                        type: string
                      max-conns:
                        type: integer
                      max-fails:
                        type: integer
                      name:
                        type: string
                      next-upstream:
                        type: string
                      next-upstream-timeout:
                        type: string
                      next-upstream-tries:
                        type: integer
                      port:
                        type: integer
                      queue:
                        description: UpstreamQueue defines Queue Configuration for an Upstream.
                        type: object
                        properties:
                          size:
                            type: integer
                          timeout:
                            type: string
                      read-timeout:
                        type: string
                      send-timeout:
                        type: string
                      service:
                        type: string
                      sessionCookie:
                        description: SessionCookie defines the parameters for session persistence.
                        type: object
                        properties:
                          domain:
                            type: string
                          enable:
                            type: boolean
                          expires:
                            type: string
                          httpOnly:
                            type: boolean
                          name:
                            type: string
                          path:
                            type: string
                          secure:
                            type: boolean
                      slow-start:
                        type: string
                      subselector:
                        type: object
                        additionalProperties:
                          type: string
                      tls:
                        description: UpstreamTLS defines a TLS configuration for an Upstream.
                        type: object
                        properties:
                          enable:
                            type: boolean
            status:
              description: VirtualServerRouteStatus defines the status for the VirtualServerRoute resource.
              type: object
              properties:
                externalEndpoints:
                  type: array
                  items:
                    description: ExternalEndpoint defines the IP and ports used to connect to this resource.
                    type: object
                    properties:
                      ip:
                        type: string
                      ports:
                        type: string
                message:
                  type: string
                reason:
                  type: string
                referencedBy:
                  type: string
                state:
                  type: string
      served: true
      storage: true
      subresources:
        status: {}
status:
  acceptedNames:
    kind: ""
    plural: ""
  conditions: []
  storedVersions: []

---

apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    controller-gen.kubebuilder.io/version: v0.4.1
  creationTimestamp: null
  name: transportservers.k8s.nginx.org
spec:
  group: k8s.nginx.org
  names:
    kind: TransportServer
    listKind: TransportServerList
    plural: transportservers
    shortNames:
      - ts
    singular: transportserver
  scope: Namespaced
  versions:
    - name: v1alpha1
      schema:
        openAPIV3Schema:
          description: TransportServer defines the TransportServer resource.
          type: object
          properties:
            apiVersion:
              description: 'APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources'
              type: string
            kind:
              description: 'Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds'
              type: string
            metadata:
              type: object
            spec:
              description: TransportServerSpec is the spec of the TransportServer resource.
              type: object
              properties:
                action:
                  description: Action defines an action.
                  type: object
                  properties:
                    pass:
                      type: string
                host:
                  type: string
                listener:
                  description: TransportServerListener defines a listener for a TransportServer.
                  type: object
                  properties:
                    name:
                      type: string
                    protocol:
                      type: string
                sessionParameters:
                  description: SessionParameters defines session parameters.
                  type: object
                  properties:
                    timeout:
                      type: string
                upstreamParameters:
                  description: UpstreamParameters defines parameters for an upstream.
                  type: object
                  properties:
                    connectTimeout:
                      type: string
                    nextUpstream:
                      type: boolean
                    nextUpstreamTimeout:
                      type: string
                    nextUpstreamTries:
                      type: integer
                    udpRequests:
                      type: integer
                    udpResponses:
                      type: integer
                upstreams:
                  type: array
                  items:
                    description: Upstream defines an upstream.
                    type: object
                    properties:
                      failTimeout:
                        type: string
                      maxFails:
                        type: integer
                      name:
                        type: string
                      port:
                        type: integer
                      service:
                        type: string
      served: true
      storage: true
status:
  acceptedNames:
    kind: ""
    plural: ""
  conditions: []
  storedVersions: []

---

apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    controller-gen.kubebuilder.io/version: v0.4.1
  creationTimestamp: null
  name: globalconfigurations.k8s.nginx.org
spec:
  group: k8s.nginx.org
  names:
    kind: GlobalConfiguration
    listKind: GlobalConfigurationList
    plural: globalconfigurations
    shortNames:
      - gc
    singular: globalconfiguration
  scope: Namespaced
  versions:
    - name: v1alpha1
      schema:
        openAPIV3Schema:
          description: GlobalConfiguration defines the GlobalConfiguration resource.
          type: object
          properties:
            apiVersion:
              description: 'APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources'
              type: string
            kind:
              description: 'Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds'
              type: string
            metadata:
              type: object
            spec:
              description: GlobalConfigurationSpec is the spec of the GlobalConfiguration resource.
              type: object
              properties:
                listeners:
                  type: array
                  items:
                    description: Listener defines a listener.
                    type: object
                    properties:
                      name:
                        type: string
                      port:
                        type: integer
                      protocol:
                        type: string
      served: true
      storage: true
status:
  acceptedNames:
    kind: ""
    plural: ""
  conditions: []
  storedVersions: []

---

apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    controller-gen.kubebuilder.io/version: v0.4.1
  creationTimestamp: null
  name: policies.k8s.nginx.org
spec:
  group: k8s.nginx.org
  names:
    kind: Policy
    listKind: PolicyList
    plural: policies
    shortNames:
      - pol
    singular: policy
  scope: Namespaced
  versions:
    - additionalPrinterColumns:
        - description: Current state of the Policy. If the resource has a valid status, it means it has been validated and accepted by the Ingress Controller.
          jsonPath: .status.state
          name: State
          type: string
        - jsonPath: .metadata.creationTimestamp
          name: Age
          type: date
      name: v1
      schema:
        openAPIV3Schema:
          description: Policy defines a Policy for VirtualServer and VirtualServerRoute resources.
          type: object
          properties:
            apiVersion:
              description: 'APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources'
              type: string
            kind:
              description: 'Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds'
              type: string
            metadata:
              type: object
            spec:
              description: PolicySpec is the spec of the Policy resource. The spec includes multiple fields, where each field represents a different policy. Only one policy (field) is allowed.
              type: object
              properties:
                accessControl:
                  description: 'AccessControl defines an access policy based on the source IP of a request. policy status: production-ready'
                  type: object
                  properties:
                    allow:
                      type: array
                      items:
                        type: string
                    deny:
                      type: array
                      items:
                        type: string
                egressMTLS:
                  description: 'EgressMTLS defines an Egress MTLS policy. policy status: preview'
                  type: object
                  properties:
                    ciphers:
                      type: string
                    protocols:
                      type: string
                    serverName:
                      type: boolean
                    sessionReuse:
                      type: boolean
                    sslName:
                      type: string
                    tlsSecret:
                      type: string
                    trustedCertSecret:
                      type: string
                    verifyDepth:
                      type: integer
                    verifyServer:
                      type: boolean
                ingressMTLS:
                  description: 'IngressMTLS defines an Ingress MTLS policy. policy status: preview'
                  type: object
                  properties:
                    clientCertSecret:
                      type: string
                    verifyClient:
                      type: string
                    verifyDepth:
                      type: integer
                jwt:
                  description: 'JWTAuth holds JWT authentication configuration. policy status: preview'
                  type: object
                  properties:
                    realm:
                      type: string
                    secret:
                      type: string
                    token:
                      type: string
                oidc:
                  description: OIDC defines an Open ID Connect policy.
                  type: object
                  properties:
                    authEndpoint:
                      type: string
                    clientID:
                      type: string
                    clientSecret:
                      type: string
                    jwksURI:
                      type: string
                    redirectURI:
                      type: string
                    scope:
                      type: string
                    tokenEndpoint:
                      type: string
                rateLimit:
                  description: 'RateLimit defines a rate limit policy. policy status: preview'
                  type: object
                  properties:
                    burst:
                      type: integer
                    delay:
                      type: integer
                    dryRun:
                      type: boolean
                    key:
                      type: string
                    logLevel:
                      type: string
                    noDelay:
                      type: boolean
                    rate:
                      type: string
                    rejectCode:
                      type: integer
                    zoneSize:
                      type: string
                waf:
                  description: 'WAF defines an WAF policy. policy status: preview'
                  type: object
                  properties:
                    apPolicy:
                      type: string
                    enable:
                      type: boolean
                    securityLog:
                      description: SecurityLog defines the security log of a WAF policy.
                      type: object
                      properties:
                        apLogConf:
                          type: string
                        enable:
                          type: boolean
                        logDest:
                          type: string
            status:
              description: PolicyStatus is the status of the policy resource
              type: object
              properties:
                message:
                  type: string
                reason:
                  type: string
                state:
                  type: string
      served: true
      storage: true
      subresources:
        status: {}
status:
  acceptedNames:
    kind: ""
    plural: ""
  conditions: []
  storedVersions: []

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-ingress
  namespace: nginx-ingress
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-ingress
  template:
    metadata:
      labels:
        app: nginx-ingress
     #annotations:
       #prometheus.io/scrape: "true"
       #prometheus.io/port: "9113"
    spec:
      serviceAccountName: nginx-ingress
      containers:
      - image: -image-
        imagePullPolicy: Always
        name: nginx-plus-ingress
        ports:
        - name: http
          containerPort: 80
        - name: https
          containerPort: 443
        - name: readiness-port
          containerPort: 8081
        - name: prometheus
          containerPort: 9113
        - name: dashboard
          containerPort: 8080
        readinessProbe:
          httpGet:
            path: /nginx-ready
            port: readiness-port
          periodSeconds: 1
        securityContext:
          allowPrivilegeEscalation: true
          runAsUser: 101 #nginx
          capabilities:
            drop:
            - ALL
            add:
            - NET_BIND_SERVICE
        env:
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        args:
          - -nginx-plus
          - -nginx-configmaps=$(POD_NAMESPACE)/nginx-config
          - -default-server-tls-secret=$(POD_NAMESPACE)/default-server-secret
          - -nginx-status-allow-cidrs=0.0.0.0/0
          - -enable-prometheus-metrics
         #- -enable-preview-policies
         #- -enable-app-protect
         #- -v=3 # Enables extensive logging. Useful for troubleshooting.
         #- -report-ingress-status
         #- -external-service=nginx-ingress
         #- -global-configuration=$(POD_NAMESPACE)/nginx-configuration

---

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
  selector:
    app: nginx-ingress
