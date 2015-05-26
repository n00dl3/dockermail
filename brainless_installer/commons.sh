#!/bin/bash
build_image(){
    $image_name=$1
    image = $(docker images | grep dockermail/$image_name)
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

RandomString(){
  < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-$1};echo;
}

gen_ssl(){

}
