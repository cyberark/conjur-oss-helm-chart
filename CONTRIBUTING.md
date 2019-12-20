# Contributing

## Table of Contents

- [Releasing](#releasing)

Majority of the instructions on how to build, develop, and run the code in
this repo is located in the main [README.md](README.md) but this file adds
any additional information for contributing code to this project.

## Releasing

To release a new version of this chart:
- Make the appropriate changes
- Update the version number
- Tag the git history with `v##.##.##` version
- Create the release on GitHub for that tag
- Build the helm chart package with `helm package conjur-oss`
- Upload that package to GitHub
- Add that chart to our [Helm charts repo](https://github.com/cyberark/helm-charts)
