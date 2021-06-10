function nsm_visibility {
  # types: cloud, kic
  # example:
  # nsm_visibility kic mydomain.com
  type=${1:-"kic"}
  domain=${2:-"example.com"}
  #https://docs.nginx.com/nginx-service-mesh/about/architecture/
  cp -f ./templates/nsm/nsm-visibility-${type}.yml.tpl ./nsm-visibility-${type}.yml
  # template
  if [[ "$type" = "kic" ]]; then
    echo "type: $type , using KIC"
    # set domain
    sed -i "s/-domain-/${domain}/g" ./nsm-visibility-${type}.yml
  else
    echo "type: $type , using loadbalancer"
  fi
  # apply
  kubectl apply -f ./nsm-visibility-${type}.yml
  # check
  kubectl get -n nginx-mesh virtualserver
  echo "=== done ==="
}
