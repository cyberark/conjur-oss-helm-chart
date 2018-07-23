# conjur-oss

[Helm](https://github.com/helm/helm) chart for [Conjur OSS](https://www.conjur.org).

## Usage

### Install

```sh-session
$ helm install ./conjur-oss
```

### Uninstall

```sh-session
$ helm ls
NAME            	REVISION	UPDATED                 	STATUS  	CHART           	NAMESPACE
coiled-wolverine	1       	Mon Jul 23 12:45:12 2018	DEPLOYED	conjur-oss-0.1.0	dustinc

$ helm delete coiled-wolverine
release "coiled-wolverine" deleted
```
