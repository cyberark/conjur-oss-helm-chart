FROM ubuntu:18.04

ENV HOME=/var/www \
    SSL_CERT_DIRECTORY=/opt/conjur/etc/ssl


EXPOSE 9000 9443

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https \
                                                      ca-certificates \
                                                      gnupg \
                                                      locales && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

RUN userdel www-data && \
    groupadd --gid 888 \
             --system www-data && \
    useradd --gid www-data \
            --home-dir "$HOME" \
            --no-create-home \
            --no-user-group \
            --shell /bin/bash \
            --system \
            --uid 888 www-data

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y jq \
                                                      keyutils \
                                                      libnss-wrapper \
                                                      ntp \
                                                      nginx \
                                                      vim && \
    apt-get clean

COPY fix-permissions /usr/bin/fix-permissions

RUN test "$(id www-data)" = "uid=888(www-data) gid=888(www-data) groups=888(www-data)" && \
    rm /var/run && \
    rm -rf $HOME \
           /etc/nginx && \
    mkdir -p $HOME \
             /etc/nginx/sites-enabled \
             /var/log/nginx \
             /var/run/nginx \
             $SSL_CERT_DIRECTORY/ca \
             $SSL_CERT_DIRECTORY/cert && \
    fix-permissions -u www-data "$HOME" \
                                "/etc/nginx" \
                                "/etc/ssl" \
                                "/var/lib/nginx" \
                                "/var/log/nginx" \
                                "/var/run/nginx" \
                                "$SSL_CERT_DIRECTORY"

COPY exec-entrypoint \
     run-nginx /usr/bin/

USER 888

ENTRYPOINT ["exec-entrypoint"]
CMD ["run-nginx"]
