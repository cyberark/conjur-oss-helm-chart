# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## Unreleased

## [v2.0.3] - 2020-12-30

### Added
- The Conjur OSS helm chart has Community support for deploying Conjur OSS to
  OpenShift 4.x.
  [cyberark/conjur-oss-helm-chart#60](https://github.com/cyberark/conjur-oss-helm-chart/issues/60)

### Changed
- The default Postgres server version is incremented to 10.15 from 10.14.
  [cyberark/conjur-oss-helm-chart#120](https://github.com/cyberark/conjur-oss-helm-chart/issues/120)

### Fixed
- Conjur pod no longer fails on restarts when the Conjur cluster is helm
  installed with the automatic Conjur account creation feature enabled (e.g.
  with `--set account.create=true`). The Conjur startup command is revised to
  check if the account exists before starting the server with the flag used to
  create it.
  [cyberark/conjur-oss-helm-chart#119](https://github.com/cyberark/conjur-oss-helm-chart/issues/119)
- Kubernetes-in-Docker example scripts no longer fail with undefined
  DOCKER_REGISTRY_PATH environment variable error.
  [cyberark/conjur-oss-helm-chart#138](https://github.com/cyberark/conjur-oss-helm-chart/issues/138)

## [v2.0.2] - 2020-12-02

### Changed
- Default Conjur version is upgraded from 1.5 to 1.11. Default Postgres
  version is upgraded from 10.12 to 10.14.
  [cyberark/conjur-oss-helm-chart#112](https://github.com/cyberark/conjur-oss-helm-chart/issues/112),
  [cyberark/conjur-oss-helm-chart#108](https://github.com/cyberark/conjur-oss-helm-chart/issues/108)
- Image `tag` values must now include surrouding quotes when they are
  set in a values.yaml file. Arbitrary tag strings are allowed now
  (e.g. "latest" is allowable).
  [cyberark/conjur-oss-helm-chart#106](https://github.com/cyberark/conjur-oss-helm-chart/issues/106)

## [v2.0.1] - 2020-10-30

### Added
- `CONJUR_LOG_LEVEL` for the Conjur container can now be configured by setting the
  `logLevel` value, or updated using `helm upgrade` [cyberark/conjur-oss-helm-chart#77](https://github.com/cyberark/conjur-oss-helm-chart/issues/77)

### Changed
- `account` now accepts two values, `account.create`, a boolean, and `account.name`, a string. 
  These values allow you to configure the creation of a Conjur account on container startup, and 
  the name of the account. [cyberark/conjur-oss-helm-chart#77](https://github.com/cyberark/conjur-oss-helm-chart/issues/78)

### Deprecated
- The `rbac.create` chart value is now deprecated. This value will be replaced in the next major
  release with two separate settings: `rbac.createClusterRole` (defaulting to true) and
  `rbac.createClusterRoleBinding` (defaulting to false). Though `ClusterRole` creation will continue
  to be supported, we recommend users migrate to using `RoleBindings` at application deploy time
  rather than relying on overprivileged `ClusterRoleBindings`.

## [v2.0.0] - 2020-06-18

### Added
- Adds password authentication for the backend Postgres database connection.
- Adds TLS support between the Conjur pod and the Postgres pod.
- Adds default auto-generation of the Postgres connection password and
  TLS certificate.
- Adds default auto-rotation of the following for `helm upgrade`:
  - Conjur TLS CA signing certificate and signed certificate for Conjur
  - Postgres database TLS certificate and key
- Adds mechanism for user to set their own TLS CA and signed certificates
  for Conjur.
 
### Changed
- Pins default Conjur version to current stable release 1.5.
- Sets default pullPolicy for Nginx and Postgres to `Always`.

### Fixed
- Fixes an issue with the use of persistent volume store so that the
  Postgres database contents are preserved across pod resets
  and helm upgrades.
  [Commit](https://github.com/cyberark/conjur-oss-helm-chart/commit/9ee5b2b191f118714193861fc75abd5226c94425),
  [Security Bulletin](https://github.com/cyberark/conjur-oss-helm-chart/security/advisories/GHSA-mg2m-623j-wpxw)

## [v1.3.8] - 2019-12-20

### Added
- Added basic instructions on how to package the chart
- Added gitleaks config to repo

### Changed
- Updated deployments to be able to run on Kubernetes 1.16+
- Updated e2e scripts to support newest helm (v.1.3.8)

### Removed
- Removed GitLab pipeline (it wasn't working anyways)

## [1.3.7] - 2019-01-31
### Changed
- Server ciphers have been upgraded to TLS1.2 levels.

## [1.3.6] - 2019-01-22
### Changed
- Changed the default Postgres resource from Pod to Deployment to fix GKE marketplace app

## [1.3.5] - 2019-01-22
### Added
- Made Postgres able to store data on a persistent volume [Issue #15](https://github.com/cyberark/conjur-oss-helm-chart/issues/15).

### Changed
- Detached the Helm chart version from docker image version.

## [1.3.4] - 2019-01-08
### Added
- New [`authenticators` parameter](./conjur-oss#configuration), optionally applied to Conjur through `CONJUR_AUTHENTICATOR` variable.
- Added SSL termination to Conjur [Issue #11](https://github.com/cyberark/conjur-oss-helm-chart/issues/11).
- Added self-signed certificate generation to the deployment.
- Added values to control usage of an existing service account or creation
- Added values to control creation of RBAC resources

### Changed
- Made ingress enabled by default.
- Changed exposed ports to be strictly https.
- Changed default service type to `NodePort` from `ClusterIP`.
- Updated version number to be in line with OSS Docker image version.

## [0.2.1] - 2018-08-01
### Added
- `app.kubernetes.io` labels are now applied by default to all resources.

## [0.2.0] - 2018-08-01
### Added
- New `deployment.annotations` parameter, optional annotations applied to Conjur deployment.
    [PR #6](https://github.com/cyberark/conjur-oss-helm-chart/pull/6)
- New `conjurLabels` and `postgresLabels` parameters,
    optional extra labels to apply to respective resources.
    [PR #5](https://github.com/cyberark/conjur-oss-helm-chart/pull/5)

## 0.1.0 - 2018-07-25
### Added
- First version of chart available.

[Unreleased]: https://github.com/cyberark/conjur-oss-helm-chart/compare/v2.0.3...HEAD
[2.0.3]: https://github.com/cyberark/conjur-oss-helm-chart/compare/v2.0.2...v2.0.3
[2.0.2]: https://github.com/cyberark/conjur-oss-helm-chart/compare/v2.0.1...v2.0.2
[2.0.1]: https://github.com/cyberark/conjur-oss-helm-chart/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/cyberark/conjur-oss-helm-chart/compare/v1.3.8...v2.0.0
[1.3.8]: https://github.com/cyberark/conjur-oss-helm-chart/compare/v1.3.7...v1.3.8
[1.3.7]: https://github.com/cyberark/conjur-oss-helm-chart/compare/v1.3.6...v1.3.7
[1.3.6]: https://github.com/cyberark/conjur-oss-helm-chart/compare/v1.3.5...v1.3.6
[1.3.5]: https://github.com/cyberark/conjur-oss-helm-chart/compare/v1.3.4...v1.3.5
[1.3.4]: https://github.com/cyberark/conjur-oss-helm-chart/compare/v0.2.1...v1.3.4
[0.2.1]: https://github.com/cyberark/conjur-oss-helm-chart/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/cyberark/conjur-oss-helm-chart/compare/v0.1.0...v0.2.0
