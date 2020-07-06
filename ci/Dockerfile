FROM google/cloud-sdk

ARG HELM_VERSION=3.1.3
ARG KUBECTL_VERSION=1.16.9

RUN mkdir -p /src
WORKDIR /src

# Install Docker client
RUN apt-get update && \
    apt-get install -y apt-transport-https \
                       ca-certificates \
                       curl \
                       gnupg2 \
                       software-properties-common \
                       wget && \
    distro="$(. /etc/os-release; echo $ID)" && \
    release="$(lsb_release -cs)" && \
    curl -fsSL "https://download.docker.com/linux/$distro/gpg" > /tmp/docker_repo_key && \
    apt-key add /tmp/docker_repo_key && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$distro $release stable" && \
    apt-get update && \
    apt-get install -y docker-ce && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Helm client
RUN wget https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    tar xvf helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/ && \
    rm helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    rm -rf linux-amd64

# Install Kubernetes client
RUN wget -O /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x /usr/local/bin/kubectl
