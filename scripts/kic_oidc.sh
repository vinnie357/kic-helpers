function kic_oidc {
  #https://github.com/nginxinc/kubernetes-ingress/tree/v1.11.3/examples-of-custom-resources/oidc
  # configure kic for oidc
  # expects kic deployed
  # pull app secrets from secrets manager
  # kic_oidc secret-name fqdn
  # ## idp
  # kubectl apply -f tls-secret.yaml
  # kubectl apply -f webapp.yaml
  # kubectl apply -f keycloak.yaml
  # kubectl apply -f virtual-server-idp.yaml

  # SECRET=value
  # echo -n $SECRET | base64
  # kubectl apply -f client-secret.yaml
  # kubectl apply -f oidc.yaml
  # ## deployment
  # kubectl apply -f nginx-ingress-headless.yaml
  # kubectl apply -f nginx-config.yaml
  # kubectl apply -f virtual-server.yaml
  echo "==== done ===="
}
