# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.1](https://github.com/cyberark/conjur-oss-helm-chart/releases/tag/v0.2.1) - 2018-08-01
### Added
- `app.kubernetes.io` labels are now applied by default to all resources.

## [0.2.0](https://github.com/cyberark/conjur-oss-helm-chart/releases/tag/v0.2.0) - 2018-08-01
### Added
- New `deployment.annotations` parameter, optional annotations applied to Conjur deployment.
    [PR #6](https://github.com/cyberark/conjur-oss-helm-chart/pull/6)
- New `conjurLabels` and `postgresLabels` parameters,
    optional extra labels to apply to respective resources.
    [PR #5](https://github.com/cyberark/conjur-oss-helm-chart/pull/5)

## [0.1.0](https://github.com/cyberark/conjur-oss-helm-chart/releases/tag/v0.1.0) - 2018-07-25
### Added
- First version of chart available.
