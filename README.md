# conjur-oss

[Helm](https://github.com/helm/helm) chart for [Conjur OSS](https://www.conjur.org).

## Usage

### Install

#### Default, latest Conjur with integrated postgres

```sh-session
$ helm install ./conjur-oss
```

This will deploy the latest version of `cyberark/conjur`.
A PostgreSQL deployment is created to store Conjur state.

#### Install a specific version of Conjur, expose it outside the cluster, use a remote database

```sh-session
$ helm install \
  --set-string image.tag=1.0.1-stable,image.pullPolicy=IfNotPresent \
  --set ingress.enabled=true,service.type=LoadBalancer \
  --set-string databaseUrl='postgres://postgres:dgsgAdGPGr4UJXi2@15.188.145.198/postgres' \
  ./conjur-oss
```

##### External database

The value of `databaseUrl` should be a PostgreSQL connection string like:

`postgres://postgres:mypassword@35.188.335.198/postgres`

This value is stored as a Kubernetes secret.

##### External IP

Note that it might take some time for the external IP to be provisioned.
Run `kubectl get svc -l app=conjur-oss` until the `EXTERNAL-IP` column resolves.

```sh-session
$ kubectl get svc -l app=conjur-oss
NAME                      TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE
loping-otter-conjur-oss   LoadBalancer   10.35.253.235   35.224.201.161   80:32576/TCP   4m

$ open http://35.224.201.161
```

Open the external IP in your web browser to see the Conjur status page.

### Uninstall

```sh-session
$ helm ls
NAME            	REVISION	UPDATED                 	STATUS  	CHART           	NAMESPACE
coiled-wolverine	1       	Mon Jul 23 12:45:12 2018	DEPLOYED	conjur-oss-0.1.0	dustinc

$ helm delete coiled-wolverine
release "coiled-wolverine" deleted
```
