FROM dockermail/web-base
RUN apt-get update && apt-get install -y php5-curl php5-json git
#remove default content of /var/www
RUN rm -rf /var/www/*
RUN git clone -b 1.6.9 --depth 1 https://github.com/RainLoop/rainloop-webmail.git /var/www

# Force initialization of data directories triggered at first program start
RUN php /var/www/index.php

RUN chown -R www-data:www-data /var/www
# TODO Move elsewhere
ADD ./on_first_run.sh /root/on_first_run.sh

EXPOSE 80
