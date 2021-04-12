# Contributing

For general contribution and community guidelines, please see the [community repo](https://github.com/cyberark/community).

## Table of Contents

- [Releasing](#releasing)
- [Contributing](#contributing)

Majority of the instructions on how to build, develop, and run the code in
this repo is located in the main [README.md](README.md) but this file adds
any additional information for contributing code to this project.

## Releasing

### Upgrading Conjur version

To upgrade the default Conjur version used by this chart, you will need to
update the following files:
- Update the [README](./conjur-oss/README.md) to change the default value for
  `image.tag` in the [Configuration table](./conjur-oss/README.md#configuration)
- Update the `tag` value for the `cyberark/conjur` image in
  [conjur-oss/values.yaml](./conjur-oss/values.yaml)

### Creating a new release

To release a new version of this chart:
- Make the appropriate changes
- Update the version number in [`conjur-oss/Chart.yaml`](conjur-oss/Chart.yaml)
- Update the CHANGELOG.md file according to the
  [Conjur community guidelines](https://github.com/cyberark/community/blob/master/Conjur/CONTRIBUTING.md#tagging)
- Tag the git history with `v##.##.##` version
- Create the release on GitHub for that tag
- Get the helm chart package from the [package action](https://github.com/cyberark/conjur-oss-helm-chart/actions/workflows/package.yml) - the
  `conjur-oss-VERSION.tgz` tarball is in the `package.zip`
- Upload the tarball to the GitHub release
- Add the chart to our [Helm charts repo](https://github.com/cyberark/helm-charts)

## Contributing

1. [Fork the project](https://help.github.com/en/github/getting-started-with-github/fork-a-repo)
2. [Clone your fork](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository)
3. Make local changes to your fork by editing files
3. [Commit your changes](https://help.github.com/en/github/managing-files-in-a-repository/adding-a-file-to-a-repository-using-the-command-line)
4. [Push your local changes to the remote server](https://help.github.com/en/github/using-git/pushing-commits-to-a-remote-repository)
5. [Create new Pull Request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork)
