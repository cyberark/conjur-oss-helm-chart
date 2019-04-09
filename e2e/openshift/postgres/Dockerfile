FROM ubuntu:18.04

ENV HOME=/var/lib/postgresql \
    PG_USER=postgres \
    PG_VERSION=9.4 \
    PG_ETC_DIR=/etc/postgresql/9.4/main \
    SSL_CERT_DIRECTORY=/opt/conjur/etc/ssl

EXPOSE 5432

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https \
                                                      ca-certificates \
                                                      gnupg \
                                                      locales && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# RH image uses 26 as the PG UID - we should try to use the same one for consistency
COPY etc/apt /etc/apt
RUN apt-key add /etc/apt/keys.d/apt.2ndquadrant.com_9904CD4BD6BAF0C3.asc && \
    groupadd --gid 260 \
             --system postgres && \
    groupadd --gid 261 \
             --system ssl-cert && \
    useradd --gid postgres \
            --groups ssl-cert \
            --home-dir /var/lib/postgresql \
            --no-create-home \
            --no-user-group \
            --shell /bin/bash \
            --system \
            --uid 26 postgres

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y jq \
                                                      keyutils \
                                                      libnss-wrapper \
                                                      ntp \
                                                      postgresql-bdr-9.4-bdr-plugin \
                                                      vim && \
    apt-get clean

COPY bin/fix-permissions /usr/bin/fix-permissions
RUN test "$(id postgres)" = "uid=26(postgres) gid=260(postgres) groups=260(postgres),261(ssl-cert)" && \
    rm /var/run && \
    rm -rf $HOME/$PG_VERSION && \
    mkdir -p /var/run/postgresql \
             $HOME \
             $PG_ETC_DIR \
             $SSL_CERT_DIRECTORY/ca \
             $SSL_CERT_DIRECTORY/cert && \
    fix-permissions -u postgres $HOME \
                                /var/run/postgresql \
                                /etc/postgresql \
                                $SSL_CERT_DIRECTORY

COPY bin /usr/bin
COPY etc /etc

# OpenShift does not present the volume with writable permissions
# TODO: Make this work:
# TODO: docs.openshift.com/enterprise/3.1/install_config/persistent_storage/pod_security_context.html
# VOLUME ["/var/lib/postgresql/$PG_VERSION"]

USER 26

ENTRYPOINT ["exec-entrypoint"]
CMD ["run-postgresql"]
