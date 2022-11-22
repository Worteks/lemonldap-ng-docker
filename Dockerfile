FROM debian:stable
MAINTAINER Clément OUDOT
LABEL name="lemonldap-ng-nginx" \
      version="v2.0.radius"

ENV SSODOMAIN=example.com \
    LOGLEVEL=info \
    DEBIAN_FRONTEND=noninteractive

EXPOSE 80

RUN echo "# Install LemonLDAP::NG source repo" && \
    apt-get -y update && \
    apt-get -y install wget apt-transport-https gnupg dumb-init && \
    wget -O - https://lemonldap-ng.org/_media/rpm-gpg-key-ow2 | apt-key add - && \
    echo "deb https://lemonldap-ng.org/deb 2.0 main" >/etc/apt/sources.list.d/lemonldap-ng.list

RUN apt-get -y update && \
    echo "# Install LemonLDAP::NG packages" && \
    apt-get -y install nginx lemonldap-ng cron anacron liblasso-perl libio-string-perl && \
    echo "# Install LemonLDAP::NG TOTP requirements" && \
    apt-get -y install libconvert-base32-perl libdigest-hmac-perl && \
    echo "# Install some DB drivers" && \
    apt-get -y install libdbd-mysql-perl libdbd-pg-perl && \
    echo "\ndaemon off;" >> /etc/nginx/nginx.conf

RUN echo "# Install lib Authen:Radius" && \
    apt-get -y install libauthen-radius-perl

COPY freeradius/dictionaries/* /etc/raddb/

COPY patch/lemonldap-ng/lemonldap-ng-portal/lib/Lemonldap/NG/Portal/Auth/Radius.pm /usr/share/perl5/Lemonldap/NG/Portal/Auth/Radius.pm
COPY patch/radiusexportedvars.ini /etc/lemonldap-ng/radiusexportedvars.ini

COPY docker-entrypoint.sh /

RUN echo '# Copy orignal configuration' && \
    cp -a /etc/lemonldap-ng /etc/lemonldap-ng-orig && \
    cp -a /var/lib/lemonldap-ng/conf /var/lib/lemonldap-ng/conf-orig && \
    cp -a /var/lib/lemonldap-ng/sessions /var/lib/lemonldap-ng/sessions-orig && \
    cp -a /var/lib/lemonldap-ng/psessions /var/lib/lemonldap-ng/psessions-orig && \
    sed '/^\[portal\]*/a ;#include /etc/lemonldap-ng/radiusexportedvars.ini\n;#endinclude /etc/lemonldap-ng/radiusexportedvars.ini' /etc/lemonldap-ng-orig/lemonldap-ng.ini > /etc/lemonldap-ng/lemonldap-ng.ini

RUN echo "# Install nginx configuration files" && \
    cd /etc/nginx/sites-enabled/ && \
    ln -s ../../lemonldap-ng/handler-nginx.conf && \
    ln -s ../../lemonldap-ng/portal-nginx.conf && \
    ln -s ../../lemonldap-ng/manager-nginx.conf && \
    ln -s ../../lemonldap-ng/test-nginx.conf


RUN echo "# Configure nginx to log to standard streams" && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/etc/lemonldap-ng","/var/lib/lemonldap-ng/conf", "/var/lib/lemonldap-ng/sessions", "/var/lib/lemonldap-ng/psessions"]

ENTRYPOINT ["dumb-init","--","/bin/sh", "/docker-entrypoint.sh"]
