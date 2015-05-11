FROM phusion/baseimage:0.9.16
RUN apt-get update && apt-get install -y apache2 php5 php5-imap php5-mysql wget
WORKDIR /tmp
RUN wget http://downloads.sourceforge.net/project/postfixadmin/postfixadmin/postfixadmin-2.92/postfixadmin-2.92.tar.gz
RUN tar -xvf postfixadmin-2.92.tar.gz
RUN rm -rf /var/www/html
RUN mv postfixadmin-2.92 /var/www/html
RUN chown -R root:www-data /var/www/html
