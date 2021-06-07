function cleanup {
  kubectl delete -f ./arcadia.yml
  kubectl delete VirtualServer arcadia
  kubectl delete -f ./nginx-ingress-install.yml
  kubectl delete -f ./nginx-ingress-dashboard.yml
  #rm ./arcadia.yml ./nginx-ingress-install.yml ./nginx-ingress-dashboard.yml
}
