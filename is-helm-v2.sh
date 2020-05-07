function is_helm_v2()
{
  # Helm Version 2 supports a `--server` command line option for the
  # `helm version` command, whereas newer versions of Helm will return
  # an error if `--server` is used.
  helm version --server > /dev/null 2>&1
}
