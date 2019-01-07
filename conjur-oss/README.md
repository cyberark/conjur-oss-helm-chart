# conjur-oss

[CyberArk Conjur Open Source](https://www.conjur.org) is a powerful secrets management solution,
tailored specifically to the unique infrastructure requirements of
native cloud, containers, and DevOps environments.
Conjur Open Source is part of the CyberArk Privileged Access Security Solution which is widely used by enterprises across the globe.

[![GitHub release](https://img.shields.io/github/release/cyberark/conjur-oss-helm-chart.svg)](https://github.com/cyberark/conjur-oss-helm-chart/releases/latest)
[![pipeline status](https://gitlab.com/cyberark/conjur-oss-helm-chart/badges/master/pipeline.svg)](https://gitlab.com/cyberark/conjur-oss-helm-chart/pipelines)

[![Github commits (since latest release)](https://img.shields.io/github/commits-since/cyberark/conjur-oss-helm-chart/latest.svg)](https://github.com/cyberark/conjur-oss-helm-chart/commits/master)

---

## Prerequisites

- Kubernetes 1.7+

## Installing the Chart

The Chart can be installed from a GitHub release Chart tarball or from source.

All releases: https://github.com/cyberark/conjur-oss-helm-chart/releases

### Simple install

Install latest Conjur with integrated Postgres.

```sh-session
$ helm install \
  --set dataKey="$(docker run --rm cyberark/conjur data-key generate)" \
  https://github.com/cyberark/conjur-oss-helm-chart/releases/download/v<VERSION>/conjur-oss-<VERSION>.tgz
```

This will deploy the latest version of `cyberark/conjur`.
The Conjur `ClusterIP` service is not exposed outside the cluster.
Conjur is running HTTPS on port 443 (9443 within the cluster) with a self-signed
certificate. A PostgreSQL deployment is created to store Conjur state.

Note that you can also install from source by cloning this repository and running

```sh-session
helm install \
  --set dataKey="$(docker run --rm cyberark/conjur data-key generate)" \
  ./conjur-oss
```

### Custom install

Install a specific version of Conjur, expose it outside the cluster with external domain name, automatic LetsEncrypt certificates, connect to a remote database.

**custom-values.yaml**

```yaml
authenticators: "authn-k8s/minikube,authn"
dataKey: "GENERATED_DATAKEY"  # docker run --rm -it cyberark/conjur data-key generate
databaseUrl: "postgres://postgres:PASSWORD@POSTGRES_ENDPOINT/postgres"

image:
  tag: "1.0.1-stable"
  pullPolicy: IfNotPresent

ssl:
  hostname: conjur.myorg.com

ingress:
  enabled: true
  annotations:
    ingress.kubernetes.io/ssl-passthrough: "false"
    nginx.ingress.kubernetes.io/ssl-passthrough: "false"
    kubernetes.io/tls-acme: "true"
  tls:
    letsencrypt:
      enabled: true
      dns01:
        provider: cloud-dns-staging
      issuerRef:
        name: "letsencrypt-staging"
        kind: ClusterIssuer
```

```sh-session
$ helm install -f custom-values.yaml \
  https://github.com/cyberark/conjur-oss-helm-chart/releases/download/v<VERSION>/conjur-oss-<VERSION>.tgz
```

Note that this requires:
- [cert-manager](https://github.com/jetstack/cert-manager) is installed, Issuers or ClusterIssuers created
- [external-dns](https://github.com/kubernetes-incubator/external-dns) is installed and configured. This may require creating a GKE service account.

This currently only does LetsEncrypt dns-01 validation.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```
$ helm delete my-release
```

The command removes all the Kubernetes components
associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the Conjur OSS chart and their default values.

|Parameter|Description|Default|
|---------|-----------|-------|
|`authenticators`|List of authenticators that Conjur will whitelist and load.|`"authn"`|
|`dataKey`|Conjur data key, 32 byte base-64 encoded string for data encryption.|`""`|
|`databaseUrl`|PostgreSQL connection string. If left blank, a PostgreSQL deployment is created.|`""`|
|`replicaCount`|Number of desired Conjur pods|`1`|
|`image.repository`|Conjur Docker image repository|`"cyberark/conjur"`|
|`image.tag`|Conjur Docker image tag|`"latest"`|
|`image.pullPolicy`|Pull policy for Conjur Docker image|`"Always"`|
|`postgres.image.repository`|postgres Docker image repository|`"postgres"`|
|`postgres.image.tag`|postgres Docker image tag|`"10.1"`|
|`postgres.image.pullPolicy`|Pull policy for postgres Docker image|`"IfNotPresent"`|
|`deployment.annotations`|Annotations for Conjur deployment|`{}`|
|`service.type`|Conjur service type|`"NodePort"`|
|`service.port`|Conjur service port|`443`|
|`service.annotations`|Annotations for Conjur service|`{}`|
|`ssl.hostname`|Hostname and Common Name for generated certificate and ingress|`"conjur.myorg.com"`|
|`ssl.altNames`|Subject Alt Names for generated Conjur certificate and ingress|`[]`|
|`ingress.enabled`|Create an Ingress resource for Conjur service|`true`|
|`ingress.annotations`|Annotations for Ingress|[See here](values.yaml#L39)|
|`ingress.tls.letsencrypt.enabled`|Automatically terminate TLS with LetsEncrypt certificates|`false`|
|`ingress.tls.letsencrypt.dns01.provider`|[cert-manager](https://github.com/jetstack/cert-manager) ClusterIssuer dns01 provider name|`nil`|
|`ingress.tls.letsencrypt.issuerRef.name`|[cert-manager](https://github.com/jetstack/cert-manager) ClusterIssuer name|`nil`|
|`ingress.tls.letsencrypt.issuerRef.kind`|[cert-manager](https://github.com/jetstack/cert-manager) ClusterIssuer kind|`nil`|
|`conjurLabels`|Extra Kubernetes labels to apply to Conjur resources|`{}`|
|`postgresLabels`|Extra Kubernetes labels to apply to Conjur PostgreSQL resources|`{}`|

## Contributing

This chart is maintained at
[github.com/cyberark/conjur-oss-helm-chart](https://github.com/cyberark/conjur-oss-helm-chart).
