FROM cyberark/conjur-kubernetes-authenticator:latest as authenticator

# Main container
FROM alpine:3.9

RUN apk add --no-cache bash \
                       jq \
                       tar \
                       wget

# Required for OpenShift since this is where the client
# cert will be injected
RUN mkdir -m 770 -p /etc/conjur/ssl

COPY --from=authenticator /bin/authenticator /usr/bin/

ENV CONJUR_VERSION=5 \
    CONTAINER_MODE=init

COPY get-seedfile \
     seedfile-extractor /usr/bin/
RUN chmod +x /usr/bin/get-seedfile \
             /usr/bin/seedfile-extractor

CMD ["get-seedfile"]
