function install_meshctl {
# requires
# nginx-meshctl download https://downloads.f5.com/
# nginx-meshctl_linux-1.0.0.gz
# example:
#install_meshctl 1.0.0
version=${1:-"1.0.0"}

FILE=nginx-meshctl_linux.gz
if test -f "$FILE"; then
    echo "installing $FILE"
    gunzip -c nginx-meshctl_linux.gz | sudo tee /usr/local/bin/nginx-meshctl > /dev/null
    sudo chmod +x /usr/local/bin/nginx-meshctl
    nginx-meshctl version
else
    echo "archive not found $FILE exiting.."
    echo "nginx-meshctl download nginx-meshctl_linux.gz https://downloads.f5.com/"
fi


}
