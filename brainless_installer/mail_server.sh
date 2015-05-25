do_build_image(){
  echo "building Dovecot image..."
  cd ./dovecot && docker build -t dockermail/dovecot . && cd ..
  echo "Done !"
}

build_mail_server_image(){
  image = $(docker images | grep dockermail/dovecot)
  if [ ! -z "$image" ];then
    echo "mail server image exists, delete it ? [y/N]"
    read DELETE
    if [ "$DELETE" == "Y" ] || [ "$DELETE" == "y" ];then
      docker rmi dockermail/dovecot
      do_build_image
    fi
  else
    do_build_image
  fi
}

run_mail_server(){
  
}
