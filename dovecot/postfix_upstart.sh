#!/bin/sh -e

# Start or stop Postfix
#
# LaMont Jones <lamont@debian.org>
# based on sendmail's init.d script


PATH=/bin:/usr/bin:/sbin:/usr/sbin
DAEMON=/usr/sbin/postfix
NAME=Postfix
TZ=
unset TZ

# Defaults - don't touch, edit /etc/default/postfix
SYNC_CHROOT="y"

test -f /etc/default/postfix && . /etc/default/postfix

test -x $DAEMON && test -f /etc/postfix/main.cf || exit 0

. /lib/lsb/init-functions
#DISTRO=$(lsb_release -is 2>/dev/null || echo Debian)

enabled_instances() {
	postmulti -l -a | awk '($3=="y") { print $1}'
}

running() {
    INSTANCE="$1"
    if [ "X$INSTANCE" = X ]; then
	    POSTCONF="postconf"
    else
	    POSTCONF="postmulti -i $INSTANCE -x postconf"
    fi

    queue=$($POSTCONF -h queue_directory 2>/dev/null || echo /var/spool/postfix)
    if [ -f ${queue}/pid/master.pid ]; then
	pid=$(sed 's/ //g' ${queue}/pid/master.pid)
	# what directory does the executable live in.  stupid prelink systems.
	dir=$(ls -l /proc/$pid/exe 2>/dev/null | sed 's/.* -> //; s/\/[^\/]*$//')
	if [ "X$dir" = "X/usr/lib/postfix" ]; then
	    echo y
	fi
    fi
}

configure_instance() {
    INSTANCE="$1"
    if [ "X$INSTANCE" = X ]; then
	    POSTCONF="postconf"
    else
	    POSTCONF="postmulti -i $INSTANCE -x postconf"
    fi


    # if you set myorigin to 'ubuntu.com' or 'debian.org', it's wrong, and annoys the admins of
    # those domains.  See also sender_canonical_maps.

    MYORIGIN=$($POSTCONF -h myorigin | tr 'A-Z' 'a-z')
    if [ "X${MYORIGIN#/}" != "X${MYORIGIN}" ]; then
	MYORIGIN=$(tr 'A-Z' 'a-z' < $MYORIGIN)
    fi
    if [ "X$MYORIGIN" = Xubuntu.com ] || [ "X$MYORIGIN" = Xdebian.org ]; then
	log_failure_msg "Invalid \$myorigin ($MYORIGIN), refusing to start"
	log_end_msg 1
	exit 1
    fi

    config_dir=$($POSTCONF -h config_directory)
    # see if anything is running chrooted.
    NEED_CHROOT=$(awk '/^[0-9a-z]/ && ($5 ~ "[-yY]") { print "y"; exit}' ${config_dir}/master.cf)

    if [ -n "$NEED_CHROOT" ] && [ -n "$SYNC_CHROOT" ]; then
	# Make sure that the chroot environment is set up correctly.
	oldumask=$(umask)
	umask 022
	queue_dir=$($POSTCONF -h queue_directory)
	cd "$queue_dir"

	# copy the CA path if specified
	ca_path=$($POSTCONF -h smtp_tls_CApath)
	case "$ca_path" in
	    '') :;; # no ca_path
	    $queue_dir/*) :;;  # skip stuff already in chroot, (and to make vim syntax happy: */)
	    *)
		if test -d "$ca_path"; then
		    dest_dir="$queue_dir/${ca_path#/}"
		    # strip any/all trailing /
		    while [ "${dest_dir%/}" != "${dest_dir}" ]; do
			dest_dir="${dest_dir%/}"
		    done
		    new=0
		    if test -d "$dest_dir"; then
			# write to a new directory ...
			dest_dir="${dest_dir}.NEW"
			new=1
		    fi
		    mkdir --parent ${dest_dir}
		    # handle files in subdirectories
		    (cd "$ca_path" && find . -name '*.pem' -print0 | cpio -0pdL --quiet "$dest_dir") 2>/dev/null ||
		        (log_failure_msg failure copying certificates; exit 1)
		    c_rehash "$dest_dir" >/dev/null 2>&1
		    if [ "$new" = 1 ]; then
			# and replace the old directory
			rm -rf "${dest_dir%.NEW}"
			mv "$dest_dir" "${dest_dir%.NEW}"
		    fi
		fi
		;;
	esac

	# if there is a CA file, copy it
	ca_file=$($POSTCONF -h smtp_tls_CAfile)
	case "$ca_file" in
	    $queue_dir/*) :;;  # skip stuff already in chroot
	    '') # no ca_file
		# or copy the bundle to preserve functionality
		ca_bundle=/etc/ssl/certs/ca-certificates.crt
		if [ -f $ca_bundle ]; then
		    mkdir --parent "$queue_dir/${ca_bundle%/*}"
		    cp -L "$ca_bundle" "$queue_dir/${ca_bundle%/*}"
		fi
		;;
	    *)
		if test -f "$ca_file"; then
		    dest_dir="$queue_dir/${ca_path#/}"
		    mkdir --parent "$dest_dir"
		    cp -L "$ca_file" "$dest_dir"
		fi
		;;
	esac

	# if we're using unix:passwd.byname, then we need to add etc/passwd.
	local_maps=$($POSTCONF -h local_recipient_maps)
	if [ "X$local_maps" != "X${local_maps#*unix:passwd.byname}" ]; then
	    if [ "X$local_maps" = "X${local_maps#*proxy:unix:passwd.byname}" ]; then
		sed 's/^\([^:]*\):[^:]*/\1:x/' /etc/passwd > etc/passwd
		chmod a+r etc/passwd
	    fi
	fi

	FILES="etc/localtime etc/services etc/resolv.conf etc/hosts \
	    etc/nsswitch.conf etc/nss_mdns.config"
	for file in $FILES; do
	    [ -d ${file%/*} ] || mkdir -p ${file%/*}
	    if [ -f /${file} ]; then rm -f ${file} && cp /${file} ${file}; fi
	    if [ -f  ${file} ]; then chmod a+rX ${file}; fi
	done
	# ldaps needs this. debian bug 572841
	(echo /dev/random; echo /dev/urandom) | cpio -pdL --quiet . 2>/dev/null || true
	rm -f usr/lib/zoneinfo/localtime
	mkdir -p usr/lib/zoneinfo
	ln -sf /etc/localtime usr/lib/zoneinfo/localtime

	LIBLIST=$(for name in gcc_s nss resolv; do
	    for f in /lib/*/lib${name}*.so* /lib/lib${name}*.so*; do
	       if [ -f "$f" ]; then  echo ${f#/}; fi;
	    done;
	done)

	if [ -n "$LIBLIST" ]; then
	    for f in "$LIBLIST"; do
		rm -f "$f"
	    done
	    tar cf - -C / $LIBLIST 2>/dev/null |tar xf -
	fi
	umask $oldumask
    fi
}


log_daemon_msg "Starting Postfix Mail Transport Agent" postfix
RET=0
# for all instances that are not already running, handle chroot setup if needed, and start
for INSTANCE in $(enabled_instances); do
  echo "instance found"
    RUNNING=$(running $INSTANCE)
    if [ "X$RUNNING" = X ]; then
    	configure_instance $INSTANCE
    	CMD="/usr/sbin/postmulti -- -i $INSTANCE -x ${DAEMON}"
      exec $CMD
    fi
done
log_end_msg $RET
exit 0
