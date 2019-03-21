FROM cyberark/conjur:latest

RUN apt-get update && \
    apt-get install -y jq \
                       tar && \
    apt-get clean

ENV SSL_CERT_DIRECTORY=/opt/conjur/etc/ssl

COPY root/usr/libexec/fix-permissions /usr/libexec/fix-permissions
RUN mkdir -p $SSL_CERT_DIRECTORY/ca && \
    mkdir -p $SSL_CERT_DIRECTORY/cert && \
    /usr/libexec/fix-permissions $SSL_CERT_DIRECTORY

COPY root /

ENTRYPOINT ["exec-entrypoint"]
CMD ["run-conjur"]
