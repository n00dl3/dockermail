FROM phusion/baseimage:0.9.16

RUN apt-get -y update

RUN apt-get install -y --force-yes wget apache2 sqlite3 libapache2-mod-php5 \
    php5-gd php5-json php5-mysql php5-curl php5-sqlite php5-imap \
    php5-intl php5-mcrypt php5-imagick

RUN wget https://download.owncloud.org/community/owncloud-8.0.2.tar.bz2
RUN tar -xvf owncloud-8.0.2.tar.bz2 --directory /var/www/ #--strip-components=1

# Generate data directory etc.
ADD ./config.php /var/www/owncloud/config/config.php
ADD ./owncloud.sh /etc/service/owncloud/run
ADD ./autoconfig.php /var/www/owncloud/config/autoconfig.php
RUN mkdir /var/www/owncloud/data
RUN chmod +x /etc/service/owncloud/run
RUN chown -R www-data:www-data /var/www/owncloud

RUN rm /etc/apache2/sites-enabled/000-default.conf
ADD ./001-owncloud.conf /etc/apache2/sites-available/
RUN ln -s /etc/apache2/sites-available/001-owncloud.conf /etc/apache2/sites-enabled/

RUN cd /var/www/owncloud/; sudo -u www-data php5 index.php
RUN php5 /var/www/owncloud/occ app:enable user_external
EXPOSE 80
