FROM ubuntu
MAINTAINER Joao Moraes joaomoraesbr@gmail.com

# Usage:
# docker run -d --name=apache-php -p 8080:80 -p 8443:443 chriswayg/apache-php

# webroot: /var/www/html/
# Apache2 config: /etc/apache2/

RUN apt-get update && \
      DEBIAN_FRONTEND=noninteractive apt-get -y install \
      apache2 \
      libapache2-mod-php5 \
      mysql-client \
      php5 \
      php5-mysql \
      php5-mcrypt \
      php5-curl \
      php5-gd \
      php5-fpm \
      php5-intl && \
    update-ca-certificates && \
    apt-get clean && rm -r /var/lib/apt/lists/*

# Apache + PHP requires preforking Apache for best results & enable Apache SSL
# forward request and error logs to docker log collector
RUN a2dismod mpm_event && \
    a2enmod mpm_prefork \
            ssl \
            rewrite && \
    a2ensite default-ssl && \
    ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log

WORKDIR /var/www/html

EXPOSE 80
EXPOSE 443

RUN rm -f /var/run/apache2/apache2.pid

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]