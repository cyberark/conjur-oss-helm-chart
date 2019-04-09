FROM ubuntu:18.04

EXPOSE 1999

ENV CONF_DIR=/etc/syslog-ng/conf.d \
    SSL_CERT_DIRECTORY=/opt/conjur/etc/ssl

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y jq \
                                                      syslog-ng

RUN groupadd --gid 555 \
             --system syslog && \
    useradd --gid syslog \
            --home-dir "/tmp" \
            --no-create-home \
            --no-user-group \
            --shell /bin/bash \
            --system \
            --uid 555 syslog

RUN rm -rf "$CONF_DIR" && \
    mkdir -p "$CONF_DIR" \
             "$SSL_CERT_DIRECTORY/ca" \
             "$SSL_CERT_DIRECTORY/cert"

COPY syslog-ng/ /etc/syslog-ng/
COPY fix-permissions \
     run-syslog-ng /usr/bin/

RUN test "$(id syslog)" = "uid=555(syslog) gid=555(syslog) groups=555(syslog)" && \
    fix-permissions -u syslog "$SSL_CERT_DIRECTORY" \
                              "/etc/syslog-ng/conf.d"

USER 555

CMD [ "run-syslog-ng" ]
