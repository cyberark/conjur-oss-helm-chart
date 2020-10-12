# Conjur OSS Helm Chart

[CyberArk Conjur Open Source](https://www.conjur.org) is a powerful secrets management solution,
tailored specifically to the unique infrastructure requirements of
native cloud, containers, and DevOps environments.
Conjur Open Source is part of the CyberArk Privileged Access Security Solution which is widely used by enterprises across the globe.

[![GitHub release](https://img.shields.io/github/release/cyberark/conjur-oss-helm-chart.svg)](https://github.com/cyberark/conjur-oss-helm-chart/releases/latest)
[![pipeline status](https://gitlab.com/cyberark/conjur-oss-helm-chart/badges/master/pipeline.svg)](https://gitlab.com/cyberark/conjur-oss-helm-chart/pipelines)

[![Github commits (since latest release)](https://img.shields.io/github/commits-since/cyberark/conjur-oss-helm-chart/latest.svg)](https://github.com/cyberark/conjur-oss-helm-chart/commits/master)

---

## Table of Contents

- [Prerequisites and Guidelines](#prerequisites-and-guidelines)
- [Installing the Chart](#installing-the-chart)
  * [Simple Install](#simple-install)
  * [Custom Installation](#custom-installation)
    + [Example: Installation Using Command Line Arguments](#example-installation-using-command-line-arguments)
    + [Example: Installation Using Custom YAML File](#example-installation-using-custom-yaml-file)
  * [Installing Conjur with an External Postgres Database](#installing-conjur-with-an-external-postgres-database)
  * [Auto-Generated Configuration](#auto-generated-configuration)
- [Upgrading, Modifying, or Migrating a Conjur OSS Helm Deployment](#upgrading-modifying-or-migrating-a-conjur-oss-helm-deployment)
  * [Modifying environment variables for an existing Conjur OSS Helm Deployment](#modifying-environment-variables-for-an-existing-conjur-oss-helm-deployment)
    + [Example: Changing Log Level](#example-changing-log-level)
- [Configuration](#configuration)
  * [Debugging](#debugging)
  * [PostgreSQL Database Password Restrictions](#postgresql-database-password-restrictions)
- [Deleting the Conjur Deployment](#deleting-the-conjur-deployment)
  * [Uninstalling the Chart via Helm Delete](#uninstalling-the-chart-via-helm-delete)
  * [Cleaning Up Kubernetes Secrets Not Managed by Helm](#cleaning-up-kubernetes-secrets-not-managed-by-helm)
- [Contributing](#contributing)

## Prerequisites and Guidelines

- Installation to an isolated Kubernetes cluster or namespace is highly
  recommended in order to facilitate limiting of direct access to Conjur
  Kubernetes resources to security administrators. Here, the term isolated
  refers to:
  * No workloads besides Conjur and its backend database running in the
    Kubernetes cluster/namespace.
  * Kubernetes and Helm access to the cluster/namespace is limited to
    security administrators via Role-Based Access Control (RBAC).
- Kubernetes 1.7+
- Helm v3+. The chart may work with older versions of
  Helm but that deployment isn't specifically supported.
- Installation on OpenShift is not currently supported.
- It is recommended that auto-upgrades of Kubernetes version not be
  used in the Kubernetes platform in which Conjur is deployed. Kubernetes
  version upgrades should be done in concert with Conjur version upgrades
  to ensure compatibility between Conjur and Kubernetes.

## Installing the Chart

The Chart can be installed from a GitHub release Chart tarball or by cloning
this GitHub repository.

All releases: https://github.com/cyberark/conjur-oss-helm-chart/releases

### Simple Install

To install Conjur with an integrated Postgres database:

```sh-session
$  CONJUR_NAMESPACE=<conjur-namespace>
$  kubectl create namespace "$CONJUR_NAMESPACE"
$  DATA_KEY="$(docker run --rm cyberark/conjur data-key generate)"
$  HELM_RELEASE=<helm-release>
$  VERSION=<conjur-oss-version>
$  helm install \
   -n "$CONJUR_NAMESPACE" \
   --set dataKey="$DATA_KEY" \
   "$HELM_RELEASE" \
   https://github.com/cyberark/conjur-oss-helm-chart/releases/download/v$VERSION/conjur-oss-$VERSION.tgz
```

_Note: The configured data key will be used to encrypt sensitive information
in Conjur's database. This must be archived in a safe place._

_Note: These commands require Helm v3+ as-written. If using Helm v2, use
arguments `--name conjur-oss` in place of `conjur-oss`._

_Note: It is highly recommended that custom, signed SSL certificates be used
rather than using auto-generated certificates for external Conjur access and
for integrated Postgres database access (see
[Custom Installation](#custom-installation) below).

Conjur is running HTTPS on port 443 (9443 within the cluster) with a self-signed
certificate. A PostgreSQL deployment is created to store Conjur state.

Note that you can also install from source by cloning this repository and running:

```sh-session
$  CONJUR_NAMESPACE=<conjur-namespace>
$  kubectl create namespace "$CONJUR_NAMESPACE"
$  DATA_KEY="$(docker run --rm cyberark/conjur data-key generate)"
$  HELM_RELEASE=<helm-release>
$  helm install \
   -n "$CONJUR_NAMESPACE" \
   --set dataKey="$DATA_KEY" \
   "$HELM_RELEASE" \
   ./conjur-oss
```

### Custom Installation

All important chart values can be customized. The table in the
[Configuration](#configuration) section below describes customizable
chart values.

Values can be customized either by:
- By including `helm install` command line arguments of the form
  `--set <key>=<value>` for any non-default configuration values (see the
  [Example: Installation Using Command Line Arguments](#example-installation-using-command-line-arguments)
  section below.
- Creating a custom version of the `values.yaml` file (see the
  [Example: Installation Using Custom YAML File](#example-installation-using-custom-yaml-file)
  section below).

_Note: When using non-default values for Helm install or upgrade,
the user is advised:_
- _Setting configurable parameters to non-default values may result in a
  combination of settings that may not have been tested._
- _Using component images other than the defaults may introduce security
  vulnerabilities._

_Note: It is recommended that any custom chart values that are sensitive in
nature should be set on the Helm command line rather than in a custom values
file (to avoid the risk of the custom values file not getting deleted after
use). An example of how to do this for `database.url` is shown below._

#### Example: Installation Using Command Line Arguments
The following shows how to install a Conjur deployment with:
- A specific version of Conjur
- A custom domain name to use for accessing Conjur from outside of the cluster

```sh-session
$  CONJUR_NAMESPACE=my-conjur-namespace
$  kubectl create namespace "$CONJUR_NAMESPACE"
$  DATA_KEY="$(docker run --rm cyberark/conjur data-key generate)"
$  HELM_ARGS="--set dataKey=$DATA_KEY \
              --set image.tag=1.5.1 \
              --set image.pullPolicy=IfNotPresent \
              --set ssl.hostname=custom.domainname.com
$  helm install \
   -n "$CONJUR_NAMESPACE" \
   $HELM_ARGS \
   conjur-oss \
   https://github.com/cyberark/conjur-oss-helm-chart/releases/download/v<VERSION>/conjur-oss-<VERSION>.tgz
```

#### Example: Installation Using Custom YAML File
The following shows how to install a Conjur deployment with:
- A specific version of Conjur
- Additional Kubernetes-API authenticators enabled
- A custom domain name to use for accessing Conjur from outside of the cluster

First, create a custom values file:

```sh-session
$  DATA_KEY="$(docker run --rm cyberark/conjur data-key generate)"
$  cat >custom-values.yaml <<EOT
authenticators: "authn-k8s/minikube,authn"
dataKey: $DATA_KEY

image:
  tag: "1.5.1"
  pullPolicy: IfNotPresent

ssl:
  hostname: custom.domainname.com
EOT
```

Next, deploy Conjur using the `custom-values.yaml` file as follows:

```sh-session
$  CONJUR_NAMESPACE=my-conjur-namespace
$  kubectl create namespace "$CONJUR_NAMESPACE"
$  helm install \
   -n "$CONJUR_NAMESPACE" \
   -f custom-values.yaml \
   conjur-oss \
   https://github.com/cyberark/conjur-oss-helm-chart/releases/download/v<VERSION>/conjur-oss-<VERSION>.tgz
```

*NOTE:* If using the Kubernetes authenticator for Conjur, the `account` value
(see [Configuration](#configuration)) must match the initial Conjur account
created. For example, given the following command:

```sh-session
$  kubectl exec -n "$CONJUR_NAMESPACE" "$POD_NAME" --container=conjur-oss conjurctl account create default
```

The chart value for `account` would be expected to equal `default`.

### Installing Conjur with an External Postgres Database

You can configure Conjur to use an external (non-integrated) Postgres database
by running `helm install` with the following command line argument (or
setting the equivalent field in a custom values.yaml file):

```
      --set database.url=<your-database-connection-string>
```

If this chart value is not explicitly set, then an integrated Postgres
database will be deployed along with Conjur.

### Auto-Generated Configuration

By default, a `helm install` of the Conjur OSS helm chart will include
automatic generation of the following configuration:

- Postgres database password (for integrated Postgres database only).

  _Note: The database password configuration is not used when an external
   Postgres database is configured._

  The database password for an integrated Postgres database is automatically
  generated if it is not set explicitly. Alternatively, the database password
  can be set explicitly by including the following `helm install` command
  line argument (or by setting the equivalent field in a custom values.yaml
  file):

  ```
      --set database.password=<your-database-password>
  ```

- Postgres database SSL certificate and key (for integrated Postgres
  database only).

  Alternatively, these values can be set explicitly with the following
  `helm install` arguments (or by setting the equivalent field in a custom
  values.yaml file):

  ```
      --set database.ssl.cert=<your-database-ssl-cert>
      --set database.ssl.key=<your-database-ssl-key>
  ```

- Conjur SSL CA signing certificate and SSL self-signed certificate.

  Alternatively, these values can be set explicitly with the following
  `helm install` arguments:

  ```
      --set ssl.caCert=<your-ssl-CA-cert>
      --set ssl.caKey=<your-ssl-CA-key>
      --set ssl.cert=<your-ssl-cert>
      --set ssl.key=<your-ssl-key>
  ```

## Upgrading, Modifying, or Migrating a Conjur OSS Helm Deployment

This Helm chart supports modifications or upgrades of a Conjur deployment via the
[helm upgrade](https://helm.sh/docs/helm/helm_upgrade/#helm) command.
This includes tasks such as rotating SSL certificates.

For details on how to upgrade or modify an existing Conjur OSS Helm deployment,
or migrate Conjur configuration from on Conjur OSS Helm deployment to a new,
separate Conjur OSS Helm deployment, please see the
[UPGRADING.md](UPGRADING.md) markdown file.

### Modifying environment variables for an existing Conjur OSS Helm Deployment

After deploying the Conjur OSS using the helm chart, you may need to add or modify an
environment variable within the Conjur container. This task can be performed without needing
to tear down your existing deployment by using the `helm upgrade` command.

#### Example: Changing Log Level

For example, to change the log-level of the Conjur container in your
deployment, run the following:

```sh-session
$  CONJUR_NAMESPACE="<conjur-namespace>"
$  HELM_RELEASE="conjur-oss"
$  LOG_LEVEL="<info, debug, etc.>
$  helm upgrade \
   -n "$CONJUR_NAMESPACE" \
   --reuse-values \
   --recreate-pods \
   --set logLevel="$LOG_LEVEL" \
   "$HELM_RELEASE" \
   ./conjur-oss
```

## Configuration

The following table lists the configurable parameters of the Conjur OSS chart and their default values.

|Parameter|Description|Default|
|---------|-----------|-------|
|`account`|Name of the Conjur account to be used by the Kubernetes authenticator|`"default"`|
|`authenticators`|List of authenticators that Conjur will whitelist and load.|`"authn"`|
|`conjurLabels`|Extra Kubernetes labels to apply to Conjur resources|`{}`|
|`database.url`|PostgreSQL connection string. If left blank, an integrated PostgreSQL deployment is created.|`""`|
|`database.password`|PostgreSQL database password string. Unused if an external Postgres database is configured. See [PostgreSQL Database Password Restrictions](#postgresql-database-password-restrictions) below.|`""`|
|`database.remotePassword`|PostgreSQL database password string. Unused if an external Postgres database is configured. See [PostgreSQL Database Password Restrictions](#postgresql-database-password-restrictions) below.|`""`|
|`database.ssl.Cert`|PostgreSQL TLS x509 certificate, base64 encoded.|`""`|
|`database.ssl.key`|PostgreSQL TLS private key, base64 encoded.|`""`|
|`dataKey`|Conjur data key, 32 byte base-64 encoded string for data encryption.|`""`|
|`deployment.annotations`|Annotations for Conjur deployment|`{}`|
|`image.repository`|Conjur Docker image repository|`"cyberark/conjur"`|
|`image.tag`|Conjur Docker image tag|`"1.5"`|
|`image.pullPolicy`|Pull policy for Conjur Docker image|`"Always"`|
|`logLevel`|Conjur log level. Set to 'debug' to enable detailed debug logs in the Conjur container |`"info"`|
|`nginx.image.repository`|NGINX Docker image repository|`"nginx"`|
|`nginx.image.tag`|NGINX Docker image tag|`"1.15"`|
|`nginx.image.pullPolicy`|Pull policy for NGINX Docker image|`"IfNotPresent"`|
|`postgres.image.pullPolicy`|Pull policy for postgres Docker image|`"IfNotPresent"`|
|`postgres.image.repository`|postgres Docker image repository|`"postgres"`|
|`postgres.image.tag`|postgres Docker image tag|`"10.12"`|
|`postgres.persistentVolume.create`|Create a peristent volume to back the PostgreSQL data|`true`|
|`postgres.persistentVolume.size`|Size of persistent volume to be created for PostgreSQL|`"8Gi"`|
|`postgres.persistentVolume.storageClass`|Storage class to be used for PostgreSQL persistent volume claim|`nil`|
|`rbac.create`|Controls whether or not RBAC resources are created|`true`|
|`replicaCount`|Number of desired Conjur pods|`1`|
|`service.external.annotations`|Annotations for the external LoadBalancer|`[service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp]`|
|`service.external.enabled`|Expose service to the Internet|`true`|
|`service.external.port`|Conjur external service port|`443`|
|`service.internal.annotations`|Annotations for Conjur service|`{}`|
|`service.internal.port`|Conjur internal service port|`443`|
|`service.internal.type`|Conjur internal service type (ClusterIP and NodePort supported)|`"NodePort"`|
|`serviceAccount.create`|Controls whether or not a service account is created|`true`|
|`serviceAccount.name`|Name of the ServiceAccount to be used by access-controlled resources created by the chart|`nil`|
|`ssl.altNames`|Subject Alt Names for generated Conjur certificate and ingress|`[]`|
|`ssl.expiration`|Expiration limit for generated certificates|`365`|
|`ssl.hostname`|Hostname and Common Name for generated certificate and ingress|`"conjur.myorg.com"`|
|`postgresLabels`|Extra Kubernetes labels to apply to Conjur PostgreSQL resources|`{}`|

### Debugging
To display additional debugging information for the Conjur container,
you can set the `logLevel` value to `debug`.

To change this value without needing to re-deploy or modify your
configuration, perform the following steps:

1. Run `helm upgrade` to change the current debug value

```sh-session
$  CONJUR_NAMESPACE="<conjur-namespace>"
$  HELM_RELEASE="conjur-oss"
$  LOG_LEVEL="debug"
$  helm upgrade \
   -n "$CONJUR_NAMESPACE" \
   --reuse-values \
   --recreate-pods \
   --set logLevel="$LOG_LEVEL" \
   "$HELM_RELEASE" \
   ./conjur-oss
```

2. _(Optional)_ Retrieve the ID of the Conjur container
```sh-session
$ POD_NAME=$(kubectl get pods \
                    --namespace $CONJUR_NAMESPACE \
                    -l "app=conjur-oss,release=conjur-oss" \
                    -o jsonpath="{.items[0].metadata.name}")

```

3. Access logs for your Conjur container
```sh-session
$ kubectl logs $POD_NAME conjur-oss
```
  - _(Optional)_ Use `-f` to follow logs
```sh-session
$ kubectl logs -f $POD_NAME conjur-oss
```

### PostgreSQL Database Password Restrictions
The following restrictions apply to the PostgreSQL database password:

- Password must only contain the following:
  - Digits (0-9)
  - Letters (A-Z,a-z)
  - The special characters:
    ["-", ".", "_", or "~"]
- Password length must be less than or equal to 64 characters.

## Deleting the Conjur Deployment

Uninstalling or deleting a Conjur deployment involves two steps:
- Running `helm delete` to delete Kubernetes resources that are
  managed directly by Helm as part of the Conjur Helm release.
- Using `kubectl delete` to delete Kubernetes secrets that are associated
  with the Conjur release, but are not managed directly by Helm.

### Uninstalling the Chart via Helm Delete
To uninstall/delete resources that are associated with a Conjur deployment
that are directly managed by Helm, use `helm delete`:

```sh-session
    $  CONJUR_NAMESPACE="<conjur-namespace>"
    $  HELM_RELEASE="conjur-oss"
    $  helm delete -n "$CONJUR_NAMESPACE" "$HELM_RELEASE"
```

### Cleaning Up Kubernetes Secrets Not Managed by Helm

Following a `helm delete` of a Conjur deployment, there may be some
residual Kubernetes secrets that have not been deleted. This will happen
whenever secrets are created for "auto-generated" Conjur configuration.
Such secrets are decorated with a "pre-install" Helm hook annotation,
essentially making these secrets "self-managed" from a Helm perspective.
The benefit to having these secrets become "self-managed" is that it prevents
loss of that configuration as a result of `helm upgrade` operations. The
downside is that those secrets are no longer cleaned up as part of
`helm delete`.

The Kubernetes secrets that may need to be manually deleted following
`helm delete` are:

|Secret Name|Description|When is Manual Deletion Required?|
|-----------|-----------|---------------------------------|
|`<helm-release>-conjur-database-password`|Database Password|When created (i.e. database URL not explicitly set)|
|`<helm-release>-remote-database-password`|Remote Database Password|When created (i.e. database URL not explicitly set)|
|`<helm-release>-conjur-database-ssl`|Database SSL Certificate|When auto-generated (i.e. not explicitly set)|
|`<helm-release>-conjur-database-url`|Database URL|When auto-generated (i.e. not explicitly set)|
|`<helm-release>-conjur-data-key`|Data encryption key|Always|
|`<helm-release>-conjur-ssl-ca-cert`|Conjur SSL CA Certificate|When auto-generated (i.e. not explicitly set)|
|`<helm-release>-conjur-ssl-cert`|Conjur SSL Access Certificate|When auto-generated (i.e. not explicitly set)|

To delete the residual "self-managed" Kubernetes secrets associated with
the Conjur deployment, run the following:

```sh-session
$  CONJUR_NAMESPACE="<conjur-namespace>"
$  HELM_RELEASE="conjur-oss"
$  kubectl delete secrets -n "$CONJUR_NAMESPACE" --selector="release=$HELM_RELEASE"
```

## Contributing

This chart is maintained at
[github.com/cyberark/conjur-oss-helm-chart](https://github.com/cyberark/conjur-oss-helm-chart).
