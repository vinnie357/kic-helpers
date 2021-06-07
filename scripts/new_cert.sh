function new_cert {
CN=${1:"kic.demo.local"}
echo "==== certs ===="
path="./certs"
mkdir -p $path
# self signed
echo "====self signed cert===="
openssl genrsa -aes256 -passout pass:1234 -out ${path}/server.pass.key 2048
openssl rsa -passin pass:1234 -in ${path}/server.pass.key -out ${path}/nginx-kic-default.key
openssl req -new -key ${path}/nginx-kic-default.key -out ${path}/server.csr -subj "/C=US/ST=testville/L=testerton/O=Test testing/OU=Test Department/CN=$CN"
openssl x509 -req -sha256 -days 365 -in ${path}/server.csr -signkey ${path}/nginx-kic-default.key -out ${path}/nginx-kic-default.crt
rm ${path}/server.pass.key
rm ${path}/server.csr
}
