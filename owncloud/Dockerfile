FROM dockermail/web-base
RUN apt-get -y update

RUN apt-get install -y php5-gd php5-json php5-mysql php5-curl php5-imap \
    php5-intl php5-mcrypt php5-imagick wget php5-cli

RUN wget https://download.owncloud.org/community/owncloud-8.0.2.tar.bz2
RUN tar -xvf owncloud-8.0.2.tar.bz2 --directory /root #--strip-components=1
RUN rm -rf /var/www
RUN mv -f /root/owncloud /var/www
# Generate data directory etc.
ADD ./config.php /var/www/config/config.php
ADD ./on_first_run.sh /root/on_first_run.sh
ADD ./autoconfig.php /var/www/config/autoconfig.php
RUN mkdir /var/www/data

RUN chown -R www-data:www-data /var/www

RUN a2enmod rewrite && php5enmod imap
