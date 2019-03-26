FROM ubuntu:18.04

EXPOSE 1999

ENV CONF_DIR=/etc/syslog-ng/conf.d

RUN DEBIAN_FRONTEND=noninteractive apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y psmisc \
                                                      syslog-ng \
                                                      vim

RUN rm -rf "$CONF_DIR" && \
    mkdir -p "$CONF_DIR"

RUN groupadd --gid 555 \
             --system syslog && \
    useradd --gid syslog \
            --home-dir "/tmp" \
            --no-create-home \
            --no-user-group \
            --shell /bin/bash \
            --system \
            --uid 555 syslog

COPY syslog-ng.conf /etc/syslog-ng/syslog-ng.conf

USER 555

ENTRYPOINT [ "/usr/sbin/syslog-ng", "--persist-file", "/tmp/syslog-ng.persist", "-d" ]
CMD [ "-f", "/etc/syslog-ng/syslog-ng.conf" ]
