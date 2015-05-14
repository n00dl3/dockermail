FROM phusion/baseimage:0.9.16
ENV     DEBIAN_FRONTEND noninteractive
MAINTAINER Round Cube <rc@xxx.org>

RUN apt-get -y update && apt-get -y upgrade
RUN apt-get install -y --no-install-recommends \
    apache2 php5 wget sqlite3 procps \
    php5-mcrypt php5-intl php5-sqlite php5-mysql php5-pgsql php-pear

RUN rm -rf /var/www/html/*
WORKDIR /root
# when roundcube grows older, change version in the download link, but also in the 'mv' command
RUN wget https://downloads.sourceforge.net/project/roundcubemail/roundcubemail/1.1.1/roundcubemail-1.1.1-complete.tar.gz -O - | tar xz
RUN mv /root/roundcubemail-1.1.1 /var/www/html
RUN mkdir /rc

ADD launch.sh /etc/service/owncloud/run
RUN chmod +x /etc/service/owncloud/run

VOLUME /rc
VOLUME /var/www/html

EXPOSE 80
