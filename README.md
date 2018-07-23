# conjur-oss

[Helm](https://github.com/helm/helm) chart for [Conjur OSS](https://www.conjur.org).

## Usage

### Install

#### Default, latest Conjur with integrated postgres

```sh-session
$ helm install ./conjur-oss
```

#### Install a specific version of Conjur

```sh-session
$ helm install --set-string image.tag=1.0.1-stable,image.pullPolicy=IfNotPresent ./conjur-oss
```

#### Install using a remote database

```sh-session
$ helm install --set-string databaseUrl=TODO ./conjur-oss
```

#### Install and expose Conjur service outside cluster

TODO

### Uninstall

```sh-session
$ helm ls
NAME            	REVISION	UPDATED                 	STATUS  	CHART           	NAMESPACE
coiled-wolverine	1       	Mon Jul 23 12:45:12 2018	DEPLOYED	conjur-oss-0.1.0	dustinc

$ helm delete coiled-wolverine
release "coiled-wolverine" deleted
```
