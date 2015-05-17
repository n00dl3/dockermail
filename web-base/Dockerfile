FROM ubuntu:14.04
ENV  DEBIAN_FRONTEND noninteractive
MAINTAINER n00dl3 <n00dl3@xxx.org>

RUN apt-get -y update && apt-get -y upgrade
RUN apt-get install -y --no-install-recommends apache2 php5 php5-mysql wget
RUN rm -rf /var/www/html
ADD run.sh /root/run.sh
ADD on_first_run.sh /root/on_first_run.sh
ADD on_run.sh /root/on_run.sh
RUN chown -R www-data:www-data /var/www
RUN mkdir /root/configured
RUN chmod +x /root/run.sh
VOLUME /root/configured
ENTRYPOINT /root/run.sh
EXPOSE 80
EXPOSE 443
