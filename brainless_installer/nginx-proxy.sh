run_nginx_proxy(){
    local INSTALL_PATH=$1
    local NGINX_PATH="$INSTALL_PATH/nginx"
    local NGINX_CERT_PATH="$NGINX_PATH/certs"
    local NGINX_TPL_PATH="$NGINX_PATH/tpl"
    if [ ! -d "$NGINX_CERT_PATH" ];then
      echo "creating folder $NGINX_CERT_PATH"
      mkdir -p $NGINX_PATH
    fi
    if [ ! -d "$NGINX_TPL_PATH" ];then
      echo "creating folder $NGINX_TPL_PATH"
      mkdir -p $NGINX_TPL_PATH
    fi
    if [ ! -f "$NGINX_TPL_PATH/nginx.tmpl" ];then
      "echo downloading nginx.tmpl..."
      wget -O $NGINX_TPL_PATH/nginx.tmpl --no-check-certificate https://raw.githubusercontent.com/jwilder/nginx-proxy/master/nginx.tmpl
    fi
    echo "starting nginx container"
    docker run -d \
    --name dockermail_nginx \
    -p 80:80 \
    -p 443:443 \
    -v $NGINX_CERT_PATH:/etc/nginx/certs \
    -v /tmp/nginx:/etc/nginx/conf.d \
    nginx
    echo "nginx container started"
    echo "starting docker-gen container..."
    docker run -d \
    --volumes-from dockermail_nginx \
    --name dockermail_docker_gen \
    -v /var/run/docker.sock:/tmp/docker.sock \
    -v $NGINX_TPL_PATH:/etc/docker-gen/templates \
    -t jwilder/docker-gen -notify-sighup dockermail_nginx -watch -only-exposed /etc/docker-gen/templates/nginx.tmpl /etc/nginx/conf.d/default.conf
    echo "done"
}
