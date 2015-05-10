FROM phusion/baseimage:0.9.16
RUN apt-get update && apt-get install -y git
#remove default content of /var/www/html
RUN rm -rf /var/www/html/*
RUN git clone -b 1.6.9 --depth 1 https://github.com/RainLoop/rainloop-webmail.git /var/www/html

RUN apt-get install -y --force-yes apache2 php5 libapache2-mod-php5 php5-curl php5-json

# Force initialization of data directories triggered at first program start
RUN php /var/www/html/index.php

RUN chown -R www-data:www-data /var/www
# TODO Move elsewhere
ADD ./create_config.sh /create_config.sh
ADD ./rainloop.sh /etc/service/rainloop/run
RUN chmod +x /etc/service/rainloop/run

EXPOSE 80
