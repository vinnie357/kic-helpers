function deploy_kic {
# deploys kic from registry
version=${1:-"1.10.0"}
registry=${2:-"registry.vin-lab.com"}
# template kic files
# modify for custom registry
# backup
cp -f ./templates/kic/nginx-ingress-install.yml.tpl ./nginx-ingress-install.yml
cp -f ./templates/kic/nginx-ingress-dashboard.yml.tpl ./nginx-ingress-dashboard.yml
sed -i "s/-image-/${registry}\/nginx-plus-ingress:${version}/g" ./nginx-ingress-install.yml

# default cert/key
secrets=$(cat -<<EOF
{
"defaultCert": "$(echo -n "$(<./certs/nginx-kic-default.crt)" | base64 -w 0)",
"defaultKey": "$(echo -n "$(<./certs/nginx-kic-default.key)" | base64 -w 0)",
"vinlabCert": "$(echo -n "$(<./certs/vin-lab.com.crt)" | base64 -w 0)",
"vinlabKey": "$(echo -n "$(<./certs/vin-lab.com.key)" | base64 -w 0)"
}
EOF
)

sed -i "s/-defaultCert-/$(echo $secrets | jq -r .defaultCert)/g" ./nginx-ingress-install.yml
sed -i "s/-defaultKey-/$(echo $secrets | jq -r .defaultKey)/g" ./nginx-ingress-install.yml

sed -i "s/-defaultCert-/$(echo $secrets | jq -r .vinlabCert)/g" ./nginx-ingress-install.yml
sed -i "s/-defaultKey-/$(echo $secrets | jq -r .vinlabKey)/g" ./nginx-ingress-install.yml

# deploy kic and dashboard
kubectl apply -f ./nginx-ingress-install.yml
# add dashboard
kubectl apply -f ./nginx-ingress-dashboard.yml

# show pods
echo " show ingress pods"
sleep 30
kubectl get pods -n nginx-ingress -o wide
#kubectl logs -f -lapp=nginx-ingress -n nginx-ingress
# finished
cd $dir
# deploy apps
cp -f ./templates/kic/arcadia.yml.tpl ./arcadia.yml
kubectl apply -f ./arcadia.yml
kubectl get svc
#nginx_ingress=$(kubectl get svc nginx-ingress --namespace=nginx-ingress -o json | jq -r .status.loadBalancer.ingress[0].ip)
# deploy ingress
cat << EOF | kubectl apply -f -
apiVersion: k8s.nginx.org/v1
kind: VirtualServer
metadata:
  name: arcadia
spec:
  host: kic.vin-lab.com
  upstreams:
  - name: arcadia-main
    service: arcadia-main
    port: 80
  - name: arcadia-app2
    service: arcadia-app2
    port: 80
  - name: arcadia-app3
    service: arcadia-app3
    port: 80
  routes:
  - path: /
    action:
      pass: arcadia-main
  - path: /app2
    action:
      pass: arcadia-app2
  - path: /app3
    action:
      pass: arcadia-app3
EOF
# done
dashboard_nginx_ingress=$(kubectl get svc dashboard-nginx-ingress --namespace=nginx-ingress -o json | jq -r .status.loadBalancer.ingress[0].ip)
echo "dashboard:"
echo "http://$dashboard_nginx_ingress/dashboard.html"
echo "app:"
echo "http://$nginx_ingress/"
echo "====Done===="

}
