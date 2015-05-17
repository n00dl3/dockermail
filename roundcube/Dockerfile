FROM dockermail/web-base
ENV     DEBIAN_FRONTEND noninteractive
MAINTAINER Round Cube <rc@xxx.org>

RUN apt-get -y update && apt-get -y upgrade
RUN apt-get install -y --no-install-recommends procps php5-mcrypt php5-intl php-pear mysql-client

WORKDIR /root
# when roundcube grows older, change version in the download link, but also in the 'mv' command
RUN wget --no-check-certificate https://downloads.sourceforge.net/project/roundcubemail/roundcubemail/1.1.1/roundcubemail-1.1.1-complete.tar.gz -O - | tar xz
RUN mv -f /root/roundcubemail-1.1.1 /var/www
RUN mkdir /rc
VOLUME /rc
ADD on_first_run.sh /root/on_first_run.sh
ADD roundcubemail.sql /root/roundcubemail.sql
ADD config.inc.php /root/config.inc.php
RUN ln -s /rc/config.inc.php /var/www/config/config.inc.php
RUN chown -R www-data:www-data /var/www

EXPOSE 80
