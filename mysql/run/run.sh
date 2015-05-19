if [ -e /run/first_launch];then
    . ./first_run.sh
    echo "done">/run/first_launch
fi
