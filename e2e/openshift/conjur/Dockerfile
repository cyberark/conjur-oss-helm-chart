FROM cyberark/conjur:latest

RUN apt-get update && \
    apt-get install -y jq \
                       tar && \
    apt-get clean

ENV TMP_DIR=/opt/conjur-server/tmp \
    SSL_CERT_DIRECTORY=/opt/conjur/etc/ssl

COPY root/usr/libexec/fix-permissions /usr/libexec/fix-permissions

RUN mkdir -p $TMP_DIR \
             $SSL_CERT_DIRECTORY/ca \
             $SSL_CERT_DIRECTORY/cert && \
    /usr/libexec/fix-permissions $TMP_DIR && \
    /usr/libexec/fix-permissions $SSL_CERT_DIRECTORY

COPY root /

ENTRYPOINT ["exec-entrypoint"]
CMD ["run-conjur"]
