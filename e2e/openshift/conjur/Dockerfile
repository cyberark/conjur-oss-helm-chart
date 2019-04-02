FROM cyberark/conjur:latest

RUN apt-get update && \
    apt-get install -y jq \
                       tar && \
    apt-get clean

ENV TMP_DIR=/opt/conjur-server/tmp \
    SSL_CERT_DIRECTORY=/opt/conjur/etc/ssl

COPY fix-permissions /usr/bin/fix-permissions

RUN mkdir -p $TMP_DIR \
             $SSL_CERT_DIRECTORY/ca \
             $SSL_CERT_DIRECTORY/cert && \
    fix-permissions "$TMP_DIR" \
                    "$SSL_CERT_DIRECTORY"

COPY follower.rb /opt/conjur-server/config/environments

COPY exec-entrypoint \
     run-conjur \
     seedfile-extractor /usr/bin/

ENTRYPOINT ["exec-entrypoint"]
CMD ["run-conjur"]
