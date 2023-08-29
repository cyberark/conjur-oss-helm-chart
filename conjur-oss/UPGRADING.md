# Upgrading, Modifying, or Migrating a Conjur Open Source Helm Deployment

This guide describes how to upgrade, modify, or migrate data from a
[CyberArk Conjur Open Source](https://www.conjur.org) (Conjur Open Source)
installation that has been deployed using the
[Conjur Open Source Helm Chart](https://github.com/cyberark/conjur-oss-helm-chart/conjur-oss).

There are two main scenarios covered in this document:
- Upgrading/Modifying an existing Conjur Open Source Helm release
- Migrating configuration from an existing Conjur Open Source Helm release
  to a new Conjur Open Source Helm Release

For more details about installing Conjur Open Source or contributing to Conjur Open Source
Helm chart development, please refer to the
[Conjur Open Source Helm Chart repository](https://github.com/cyberark/conjur-oss-helm-chart/conjur-oss).

To see what Conjur Open Source Helm chart configurations can be upgraded/updated,
please refer to the [Configuration](README.md#configuration) section of
the Conjur Open Source Helm chart [README.md](README.md) file.

---

## Table of Contents

- [Prerequisites and Guidelines](#prerequisites-and-guidelines)
- [Upgrading/Modifying a Conjur Open Source Helm Release](#upgradingmodifying-a-conjur-open-source-helm-release)
  * [Running Helm Upgrade](#running-helm-upgrade)
    + [Example: Upgrading Conjur Version](#example-upgrading-conjur-version)
    + [Example: Upgrading NGINX Version](#example-upgrading-nginx-version)
  * [Rotating the SSL Certificate for an Integrated Postgres Database](#rotating-the-ssl-certificate-for-an-integrated-postgres-database)
  * [Rotating the Conjur SSL CA and Access Certificates](#rotating-the-conjur-ssl-ca-and-access-certificates)
  * [Updating the Database URL for an External Postgres Database](#updating-the-database-url-for-an-external-postgres-database)
- [Migrating Conjur Open Source Configuration to a New Conjur Open Source Helm Release](#migrating-conjur-oss-configuration-to-a-new-conjur-open-source-helm-release)
  * [Overview](#overview)
  * [Assumptions and Limitations](#assumptions-and-limitations)
  * [Migrating Conjur Open Source Configuration With Integrated Postgres Database](#migrating-conjur-open-source-configuration-with-integrated-postgres-database)
    + [Step 1: Save Helm State and Kubernetes Secrets Data](#step-1-save-helm-state-and-kubernetes-secrets-data)
    + [Step 2: Save Postgres Database State](#step-2-save-postgres-database-state)
    + [Step 3: Uninstall Original Conjur Open Source Helm Release](#step-3-uninstall-original-conjur-open-source-helm-release)
    + [Step 4: Helm Install a New Conjur Open Source Deployment](#step-4-helm-install-a-new-conjur-open-source-deployment)
    + [Step 5: Restore the Postgres Database](#step-5-restore-the-postgres-database)
    + [Step 6: Redeploy helm chart with updated 'replicaCount'](#step-6-redeploy-helm-chart-with-updated-replicaCount)
  * [Migrating Conjur Open Source Configuration With External Postgres Database](#migrating-conjur-open-source-configuration-with-external-postgres-database)
    + [Step 1: Save Helm State and Kubernetes Secrets Data](#step-1-save-helm-state-and-kubernetes-secrets-data)
    + [Step 2: Uninstall Original Conjur Open Source Helm Release](#step-2-uninstall-original-conjur-open-source-helm-release)
    + [Step 3: Helm Install a New Conjur Open Source Deployment](#step-3-helm-install-a-new-conjur-open-source-deployment)

## Prerequisites and Guidelines

Please refer to the
[Prerequisites and Guidelines](README.md#prerequisites-and-guidelines)
section of Conjur Open Source helm chart [README.md](README.md) file for overall
prerequisites and guidelines for using the Conjur Open Source helm chart.

## Upgrading/Modifying a Conjur Open Source Helm Release

This Helm chart supports modifications or upgrades of a Conjur deployment via
`helm upgrade`. There are three upgrade scenarios to consider, depending on
whether there are any major (breaking) version changes for the release
components:

- Conjur
- NGINX
- Postgres

and depending on whether the Helm chart used for upgrade is different than
that used for Helm install:

|Component Version Changes|Chart Version Used for Upgrade|Currently Supported?|Notes|
|-------------------------|------------------------------|:------------------:|:---:|
|Minor (i.e. non-breaking)|Same version as Helm install|**YES**||
|Minor (i.e. non-breaking)|Different version than Helm install|**YES**||
|Major (breaking)|Same or different than Helm install|**NO**|**Note 1, Note 2**|

_**Note 1**: To determine if a version change/bump is considered a breaking change, refer
to this repository's `CHANGELOG.md` file for the respective current vs. new
helm chart version._

_**Note 2**: Details on how upgrades involving breaking changes to Conjur, NGINX,
or PostgreSQL will be supported in future releases are TBD._

### Running Helm Upgrade

To perform a Helm upgrade, run the following (replacing `<conjur-namespace>`
with your Conjur deployment namespace):

```sh-session
$  CONJUR_NAMESPACE="<conjur-namespace>"
$  HELM_RELEASE="conjur-oss"
$  helm upgrade \
   -n "$CONJUR_NAMESPACE" \
   --reuse-values \
   < INSERT YOUR --set CUSTOMIZATION SETTINGS HERE > \
   "$HELM_RELEASE" \
   https://github.com/cyberark/conjur-oss-helm-chart/releases/download/v<VERSION>/conjur-oss-<VERSION>.tgz
```

Or if you've cloned the https://github.com/cyberark/conjur-oss-helm-chart
repository (replacing `<conjur-namespace>` with your Conjur deployment namespace):

```sh-session
$  CONJUR_NAMESPACE="<conjur-namespace>"
$  HELM_RELEASE="conjur-oss"
$  helm upgrade \
   -n "$CONJUR_NAMESPACE" \
   --reuse-values \
   < INSERT YOUR --set CUSTOMIZATION SETTINGS HERE > \
   "$HELM_RELEASE" \
   ./conjur-oss
```

Some notes:

- The `--reuse-values` is required to preserve any non-default values
  that were used during your previous `helm install`.
- Custom values that can be set via `--set` are described in the
  [Custom Installation](README.md#custom-installation) section of the
  [README.md](README.md) file.
- The master data key used in the `helm install` is preserved for `helm
  upgrade` operations. It is not possible to modify the master data key
  via `helm upgrade`.
- The database password used by an integrated Postgres database is preserved
  for `helm upgrade`. It is not possible to modify the database password
  via `helm upgrade`.
- By default, the Postgres database SSL self-signed certificate and key are
  preserved for `helm upgrade`. To rotate the database SSL certificate and
  key, see the
  [Rotating the SSL Certificate for an Integrated Postgres Database](#rotating-the-ssl-certificate-for-an-integrated-postgres-database)
  section below.
- By default, the Conjur CA certificate and self-signed certificate (for
  external access) are preserved for `helm upgrade`. To rotate the Conjur
  CA and self-signed certificates, see the
  [Rotating the Conjur SSL CA and Self-Signed Certificates](#rotating-the-conjur-ssl-ca-and-self-signed-certificates)
  section below.

#### Example: Upgrading Conjur Version

For example, to upgrade the version of Conjur that is used in the Conjur
deployment, run the following:

```sh-session
$  CONJUR_NAMESPACE="<conjur-namespace>"
$  HELM_RELEASE="conjur-oss"
$  helm upgrade \
   -n "$CONJUR_NAMESPACE" \
   --reuse-values \
   --set image.tag="<new-conjur-version>" \
   "$HELM_RELEASE" \
   ./conjur-oss
```

#### Example: Upgrading NGINX Version

For example, to change the version of NGINX that is used in the Conjur
deployment, run the following:

```sh-session
$  CONJUR_NAMESPACE="<conjur-namespace>"
$  HELM_RELEASE="conjur-oss"
$  helm upgrade \
   -n "$CONJUR_NAMESPACE" \
   --reuse-values \
   --set nginx.image.tag="<nginx-version>" \
   "$HELM_RELEASE" \
   ./conjur-oss
```

### Rotating the SSL Certificate for an Integrated Postgres Database

If a Helm deployment of Conjur Open Source included the deployment of an integrated
Postgres database (i.e. the `database.url` chart value was not explicitly
set for `helm install`), then `helm upgrade` operations will by default
preserve the self-signed SSL certificate and key used to access the
integrated database.

Alternatively, the integrated database SSL certificate and key can be
manually updated (or "rotated") as follows:

1. Generate a self-signed certificate and key.

2. Delete the Kubernetes secret for the database SSL certificate. (Note:
   this is optional if the current database SSL certificate was set
   explicitly, but mandatory if the SSL certificate and key were
   auto-generated by the Conjur Open Source Helm chart):

```sh-session
$  CONJUR_NAMESPACE="<conjur-namespace>"
$  HELM_RELEASE="conjur-oss"
$  CERT_SECRET=$(kubectl get secrets \
       -n "$CONJUR_NAMESPACE" \
       -l "app=conjur-oss,release=$HELM_RELEASE" \
       -o name \
       | grep conjur-database-ssl)
$  kubectl delete -n "$CONJUR_NAMESPACE" "$CERT_SECRET"
```

3. Run `helm upgrade`, setting the certificate values from Step 1:

```sh-session
$  helm upgrade \
       -n "$CONJUR_NAMESPACE" \
       --reuse-values \
       --set database.ssl.cert="<new-ssl-cert>" \
       --set database.ssl.key="<new-ssl-key>" \
       "$HELM_RELEASE" \
       ./conjur-oss
```

### Rotating the Conjur SSL CA and Access Certificates

By default, a `helm upgrade` operation will preserve the SSL CA certificate
and key used for signing and the SSL certificate and key used for
external Conjur access.

Alternatively, the Conjur SSL CA and SSL access certificates can be manually
updated (or "rotated") as follows:

1. Generate an SSL CA self-signing certificate and key and a self-signed
   certificate and key for external Conjur access.

2. Delete the Kubernetes secrets for the Conjur CA signing certificate and
   the Conjur self-signed certificate. (Note: This step is optional if the
   current Conjur CA and self-signed certificates were set explicitly, but
   mandatory if these certificates were auto-generated by the Conjur
   OSS Helm chart):

```sh-session
$  CONJUR_NAMESPACE="<conjur-namespace>"
$  HELM_RELEASE="conjur-oss"
$  CA_SECRET=$(kubectl get secrets \
       -n "$CONJUR_NAMESPACE" \
       -l "app=conjur-oss,release=$HELM_RELEASE" \
       -o name \
       | grep conjur-ssl-ca-cert)
$  kubectl delete -n "$CONJUR_NAMESPACE" "$CA_SECRET"
$  CERT_SECRET=$(kubectl get secrets \
       -n "$CONJUR_NAMESPACE" \
       -l "app=conjur-oss,release=$HELM_RELEASE" \
       -o name \
       | grep conjur-ssl-cert)
$  kubectl delete -n "$CONJUR_NAMESPACE" "$CERT_SECRET"
```

3. Run `helm upgrade`, setting the certificate values from Step 1:

```sh-session
$  helm upgrade \
       -n "$CONJUR_NAMESPACE" \
       --reuse-values \
       --set ssl.caCert="<new-ssl-CA-cert>" \
       --set ssl.caKey="<new-ssl-CA-key>" \
       --set ssl.cert="<new-ssl-cert>" \
       --set ssl.key="<new-ssl-key>" \
       "$HELM_RELEASE" \
       ./conjur-oss
```

### Updating the Database URL for an External Postgres Database

If you are using an external Postgres database for your Conjur deployment
(i.e. you had explicitly set the `database.url` chart value in your
prior `helm install`), then by default any `helm upgrade` operation that
uses the `--reuse-values` flag will preserve that `database.url` value.

On the other hand, if you need to update the `database.url` connection
string for some reason (e.g. the domain name or password for
the external Postgres database has been changed), then you **must
update the database URL by doing a `helm upgrade` that uses the command
line argument `--set "database.url=<new-database-url>"`**:

```sh-session
$  CONJUR_NAMESPACE="<conjur-namespace>"
$  HELM_RELEASE="conjur-oss"
$  helm upgrade \
       -n "$CONJUR_NAMESPACE" \
       --reuse-values \
       --set "database.url=<new-database-url>" \
       "$HELM_RELEASE" \
       ./conjur-oss
```

## Migrating Conjur Open Source Configuration to a New Conjur Open Source Helm Release

### Overview

In some cases, it may be desirable to migrate Conjur configuration from
one Conjur Open Source Helm release to a new, separate Helm release. For example,
you may want to migrate your Conjur Open Source deployment to a different
Kubernetes provider, or you may want to move your Conjur Open Source deployment
to a more secure Kubernetes environment.

This section provides the steps for extracting Conjur configuration from
an existing Conjur Open Source Helm deployment, and restoring that Conjur configuration
on a new, separate Conjur Open Source Helm deployment.

The backup operation from the original Conjur Open Source deployment involves
extracting Conjur Open Source state from three sources:

- Kubernetes secrets
- Helm state
- Postgres database state

The restore operation to the new Conjur Open Source deployment involves:

- Running `helm init` to restore Helm state and Kubernetes secrets
- Postgres restore of Conjur's database state

### Assumptions and Limitations

- Currently, _the version of Conjur for the new Conjur Open Source deployment
  **MUST** be the same as the version of Conjur on the original Conjur
  OSS deployment_. (Support for migration to different versions of Conjur
  may be available in the future, but this will require schema translation
  logic that is TBD).
- For deployments using an integrated Postgres database, _the **major**
  version of Postgres in the new Conjur Open Source deployment must be the
  same as the **major** version of Postgres in the original deployment_.
- For simplicity, the instructions described here will include the
  recreation of only a critical **subset** of Helm state from the old Conjur
  deployment to new deployment. It is possible to modify the steps to
  include transfer of more Helm state, but that is left out-of-scope for
  simplicity in these instructions.

  The Helm values that are included in the migration described here:
  - `account.name`
  - `authenticators`
  - `database.password`
  - `database.url`
  - `dataKey`

  The Helm values that are left out for simplicity and brevity are all
  other Helm chart values listed in the
  [Configuration](README.md#configuration) section of the
  [README.md](README.md) file.

- _**All instructions that follow assume that you are in the base of
  https://github.com/cyberark/conjur-oss-helm-chart repo**_

### Migrating Conjur Open Source Configuration With Integrated Postgres Database

When a Conjur Open Source Helm deployment includes an integrated (internal) Postgres
database, the procedure for migrating Conjur Open Source state to a new Conjur Open Source
Helm deployment is as follows:

#### Step 1: Save Helm State and Kubernetes Secrets Data

_This assumes that only Conjur is in the specified namespace.
 If not, manually set the `helm_chart_name` variable_

(Replace `<conjur-namespace>` with your Conjur deployment namespace.)

```sh-session
$  namespace="<conjur-namespace>"

$  helm_chart_name=$(helm list -n "$namespace" -q)
$  account=$(helm show values "$helm_chart_name" | \
             awk '/^account\.name:/{print $2}' | \
             sed -e 's/^"//' -e 's/"$//')
$  authenticators=$(kubectl get secret \
             -n "$namespace" \
             "${helm_chart_name}-conjur-authenticators" \
             -o jsonpath="{.data.key }" | \
             base64 --decode)
$  data_key=$(kubectl get secret \
             -n "$namespace" \
             "${helm_chart_name}-conjur-data-key" \
             -o jsonpath="{.data.key }" | \
             base64 --decode)
```

Next, check your Conjur Open Source chart version:

```sh-session
$  helm show chart "$helm_chart_name"| awk '/^version:/{print $2}'
```

If your Conjur Open Source chart version is 2.0.0 or newer, then you will also need
to store the database password:
```sh-session
$  db_password=$(kubectl get secret \
             -n "$namespace" \
             "${helm_chart_name}-conjur-database-password" \
             -o jsonpath="{.data.key }" | \
             base64 --decode)
```

#### Step 2: Save Postgres Database State

```sh-session
#  Get name of the Postgres pod in the current deployment
$  postgres_old_pod=$(kubectl get pods \
             -n "$namespace" \
             -l "app=conjur-oss-postgres" \
             -o jsonpath="{.items[0].metadata.name}")

#  Run the `pg_dump` utility to create a database archive file
$  kubectl exec -it \
             -n "$namespace" \
             $postgres_old_pod \
             -- pg_dump -U postgres -c -C --column-inserts \
                        --inserts -f /dbdump.tar -F tar

#  Copy the database archive file from the Postgres pod to your local machine
$  kubectl cp -n "$namespace" $postgres_old_pod:dbdump.tar dbdump.tar
```

#### Step 3: Uninstall Original Conjur Open Source Helm Release

Run `helm uninstall ...` to delete the original Conjur Open Source Helm release
and delete any residual, "self-managed" Kubernetes secrets.

**WARNING: This will remove your old certificates!**

```sh-session
$  helm uninstall -n "$namespace" $helm_chart_name
$  kubectl delete secrets -n "$namespace" -l release="$helm_chart_name"
```

#### Step 4: Helm Install a New Conjur Open Source Deployment

**WARNING: This will possibly change your external service IP!**

_This new deployment is unusable in this state as a regular deployment since
 the `replicaCount` is temporarily set to 0 (which is intentional). The
 `helm upgrade` in [Step 6](#step-6-redeploy-helm-chart-with-updated-replicacount)
 below will enable it._

```sh-session
$  namespace="<conjur-namespace>"
$  helm_chart_name=conjur-oss
$  helm install \
        -n "$namespace" \
        --set account.name="$account" \
        --set authenticators="$authenticators" \
        --set database.password="$db_password" \
        --set dataKey="$data_key" \
        --set replicaCount=0 \
        $helm_chart_name \
        ./conjur-oss
```

#### Step 5: Restore the Postgres Database

_We use the `template1` part of the connection string to delete and recreate the database.
This assumes that database names have not changed between upgrades. Replace `postgres` in the
`sed` command if your connection string used a different database name._

```sh-session
#  Get the name of the Postgres pod in the new deployment
$  postgres_new_pod=$(kubectl get pods \
            -n "$namespace" \
            -l "app=conjur-oss-postgres" \
            -o jsonpath="{.items[0].metadata.name}")

#  Copy the database archive file from your local machine to the Postgres 
#  pod in the new deployment
$  kubectl cp -n "$namespace" ./dbdump.tar $postgres_new_pod:/dbdump.tar

#  Run the `pg_restore` utility to restore the database archive file to
#  the Postgres pod.
$  pg_restore_connection_string=$(kubectl get secret \
            -n "$namespace" \
            ${helm_chart_name}-conjur-database-url \
            -o jsonpath="{.data.key}" | \
            base64 --decode | \
            sed 's/postgres?/template1?/')
$  kubectl exec -it -n "$namespace" \
            $postgres_new_pod \
            -- pg_restore -C -c -d "$pg_restore_connection_string" /dbdump.tar

#  Remove the database archive file from the Postgres pod
$  kubectl exec -it -n "$namespace" \
            $postgres_new_pod \
            -- rm -rf /dbdump.tar
```

#### Step 6: Redeploy Helm Chart With Updated `replicaCount`

```sh-session
$  helm upgrade -n "$namespace" \
                --reuse-values \
                --set replicaCount="1" \
                $helm_chart_name \
                ./conjur-oss
```

### Migrating Conjur Open Source Configuration With External Postgres Database

When a Conjur Open Source Helm deployment includes an external Postgres database,
the procedure for migrating Conjur Open Source state to a new Conjur Open Source Helm
deployment is as follows:

#### Step 1: Save Helm State and Kubernetes Secrets Data

_This assumes that only Conjur is in the specified namespace.
 If not, manually set the `helm_chart_name` variable_

```sh-session
$  namespace="<conjur-namespace>"

$  helm_chart_name=$(helm list -n "$namespace" -q)
$  account=$(helm show values "$helm_chart_name" | \
             awk '/^account\.name:/{print $2}' | \
             sed -e 's/^"//' -e 's/"$//')
$  authenticators=$(kubectl get secret \
             -n "$namespace" \
             "${helm_chart_name}-conjur-authenticators" \
             -o jsonpath="{.data.key }" | \
             base64 --decode)
$  data_key=$(kubectl get secret \
             -n "$namespace" \
             "${helm_chart_name}-conjur-data-key" \
             -o jsonpath="{.data.key }" | \
             base64 --decode)
$  db_url=$(kubectl get secret \
             -n "$namespace" \
             "${helm_chart_name}-conjur-database-url" \
             -o jsonpath="{.data.key }" | \
             base64 --decode)
```

#### Step 2: Uninstall Original Conjur Open Source Helm Release

Run `helm uninstall ...` to delete the original Conjur Open Source Helm release
and delete any residual, "self-managed" Kubernetes secrets.

**WARNING: This will remove your old certificates!**

```sh-session
$  helm uninstall -n "$namespace" $helm_chart_name
$  kubectl delete secrets -n "$namespace" -l release="$helm_chart_name"
```

#### Step 3: Helm Install a New Conjur Open Source Deployment

**WARNING: This will possibly change your external service IP!**

```sh-session
$  namespace="<conjur-namespace>"
$  helm_chart_name=conjur-oss
$  helm install \
        -n "$namespace" \
        --set account.name="$account" \
        --set authenticators="$authenticators" \
        --set database.url="$db_url" \
        --set dataKey="$data_key" \
        $helm_chart_name \
        ./conjur-oss
```
