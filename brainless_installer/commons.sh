#!/bin/bash
build_image(){
    local image_name=$1
    local image=$(docker images | grep dockermail/$image_name)
    if [ ! -z "$image" ];then
      echo "dockermail/$image_name image exists, delete it ? [y/N]"
      read DELETE
      if [ "$DELETE" == "Y" ] || [ "$DELETE" == "y" ];then
        docker rmi dockermail/$image_name
        echo "building dockermail/$image_name ..."
        cd ./$image_name && docker build -t dockermail/$image_name . && cd ..
        echo "Done !"
      fi
    else
        echo "building dockermail/$image_name image..."
        cd ./$image_name && docker build -t dockermail/$image_name . && cd ..
        echo "Done !"
    fi
}
stop_container(){
  local container_name=$1
  local container=$(docker ps | grep dockermail_$container_name)
  if [ ! -z "$container" ];then
    read -p "dockermail_$container_name is running, stop and remove it ? [Y/n]" stop
    if [ "$stop" != "n" ] && [ "$stop" != "N" ];then
      docker stop $container_name
      docker rm -v $container_name
      return 0
    fi
    return 2
  fi
  return 0
}

RandomString(){
  < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-$1};echo;
}

gen_ssl_certs(){
  local crt_out=$1
  local key_out=$2
  local domain=$3
  local subject="/C=$COUNTRY"
  if [ ! -z "$STATE" ];then
    subject="$subject/ST=$STATE"
  fi
  if [ ! -z "$CITY" ];then
    subject="$subject/L=$CITY"
  fi
  if [ ! -z "$ORGANIZATION" ];then
    subject="$subject/O=$ORGANIZATION"
  fi
  subject="$subject/CN=$domain"
  openssl req -x509 -nodes -days 3650 -subj "$subject" -newkey rsa:1024 -keyout $key_out -out $crt_out
}
