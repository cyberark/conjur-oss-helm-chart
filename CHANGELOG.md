# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/cyberark/conjur-oss-helm-chart/compare/v1.3.7...HEAD
[1.3.7]: https://github.com/cyberark/conjur-oss-helm-chart/compare/v1.3.6...v1.3.7
[1.3.6]: https://github.com/cyberark/conjur-oss-helm-chart/compare/v1.3.5...v1.3.6
[1.3.5]: https://github.com/cyberark/conjur-oss-helm-chart/compare/v1.3.4...v1.3.5
[1.3.4]: https://github.com/cyberark/conjur-oss-helm-chart/compare/v0.2.1...v1.3.4
[0.2.1]: https://github.com/cyberark/conjur-oss-helm-chart/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/cyberark/conjur-oss-helm-chart/compare/v0.1.0...v0.2.0
