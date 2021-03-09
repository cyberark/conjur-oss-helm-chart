# All-in-One Demo: Deploy Kubernetes, Conjur OSS, and Applications that Retrieve Secrets Securely

## Table of Contents
  * [What This Demonstration Does](#what-this-demonstration-does)
  * [Prerequisites](#prerequisites)
  * [Let's Run the Demo!](#lets-run-the-demo-)
  * [Behind the Scenes: So What Did this Demo Just Do?](#behind-the-scenes-so-what-did-this-demo-just-do-)
    + [Background: The Conjur Kubernetes Authenticator and Conjur Application Identity](#background-the-conjur-kubernetes-authenticator-and-conjur-application-identity)
    + [Demo Script Workflow](#demo-script-workflow)
    + [Exploring The Local KinD Cluster](#exploring-the-local-kind-cluster)
    + [Exploring the `conjur-oss` Namespace](#exploring-the-conjur-oss-namespace)
    + [Viewing Rendered Conjur-OSS Security Policy](#viewing-rendered-conjur-oss-security-policy)
    + [Exploring the Demo Application `app-test` Namespace](#exploring-the-demo-application-app-test-namespace)
  * [Customizable Demo Settings](#customizable-demo-settings)
    + [How to Modify Customizable Demo Settings](#how-to-modify-customizable-demo-settings)
    + [Example: Configuring a Docker Registry](#example-configuring-a-docker-registry)
  * [Enabling Conjur Debug Logging](#enabling-conjur-debug-logging)
  * [Cleaning Up](#cleaning-up)
    + [Deleting the Kubernetes Conjur Demo Applications](#deleting-the-kubernetes-conjur-demo-applications)
    + [Uninstalling Conjur OSS via Helm Delete](#uninstalling-conjur-oss-via-helm-delete)
    + [Deleting the KinD Cluster](#deleting-the-kind-cluster)

## What This Demonstration Does

The scripts in this directory can be  used to run an "All-in-One"
demonstration of how Conjur OSS  can be deployed along with a simple
[Pet Store](https://github.com/conjurdemos/pet-store-demo/) application
that securely retrieves application-specific secrets from Conjur OSS.

It is not necessary for you to have access to a Kubernetes cluster
before running the scripts. The scripts conveniently create a local,
containerized Kubernetes cluster for the demo using
[Kubernetes-in-Docker](https://github.com/kubernetes-sigs/kind) (KinD).

The scripts demonstrate the various choices of Conjur authentication
broker/clients that you have available for empowering an application for
securely accessing secrets via Conjur:
  - [Secretless Broker](https://github.com/cyberark/secretless-broker) sidecar container
  - [Conjur Kubernetes Authenticator Client](https://github.com/cyberark/conjur-authn-k8s-client)
    sidecar container
  - [Conjur Kubernetes Authenticator Client](https://github.com/cyberark/conjur-authn-k8s-client)
    init container

The scripts also demonstrate how Conjur authentication uses
[Conjur application identity](https://docs.conjur.org/Latest/en/Content/Integrations/Kubernetes_AppIdentity.htm?TocPath=Integrations%7COpenShift%252C%20Kubernetes%252C%20and%20GKE%7C_____2)
to uniquely identify and authenticate the application before it is permitted
to access application-specific secrets from Conjur.

## Prerequisites

- Linux or MacOS host that is running [Docker](https://docs.docker.com/get-docker/)
- [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
  client version 1.13 or newer.

  <details>
    <summary>Click to expand installation examples.</summary>

    ##### Install `kubectl` on Linux

    ```sh-session
        # Download the binary, make it executable, and move it to your PATH
        curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.19.0/bin/linux/amd64/kubectl
        chmod +x ./kubectl
        sudo mv ./kubectl /usr/local/bin
    ```

    ##### Install `kubectl` on MacOS

    ```sh-session
        brew install kubernetes-cli
    ```

  </details>

- [Kubernetes-in-Docker (`kind`)](https://kind.sigs.k8s.io/docs/user/quick-start#installation)
  binary version 0.7.0 or newer.

  <details>
    <summary>Click to expand installation examples.</summary>

    ##### Install `kind` on Linux

    ```sh-session
        # Download the binary, make it executable, and move it to your PATH
        curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.9.0/kind-linux-amd64
        chmod +x ./kind
        sudo mv ./kind /usr/local/bin
    ```

    ##### Install `kind` on MacOS

    ```sh-session
        brew install kind
    ```
  </details>

- [`helm`](https://helm.sh/docs/intro/install/) client version 3 or newer.

  <details>
    <summary>Click to expand installation examples.</summary>

    ##### Installing `helm` on Linux:

    ```sh-session
        # Download the release tar file, unpack it, and copy the client to your PATH
        mkdir -p ~/temp/helm-v3.3.1
        cd ~/temp/helm-v3.3.1
        helm_tar_file=helm-v3.3.1-linux-amd64.tar.gz
        curl https://get.helm.sh/"$helm_tar_file" --output "$helm_tar_file"
        tar -zxvf "$helm_tar_file"
        sudo mv linux-amd64/helm /usr/local/bin
    ```

    ##### Installing `helm` on MacOS:

    ```sh-session
        brew install helm
    ```
  </details>

## Let's Run the Demo!

1. Clone the
   [Conjur OSS Helm Chart](https://github.com/cyberark/conjur-oss-helm-chart)
   GitHub repository, if you haven't done so already.

   <details>
     <summary>Click to expand cloning commands.</summary>

     ```sh-session
         mkdir -p ~/cyberark
         cd ~/cyberark
         git clone https://github.com/cyberark/conjur-oss-helm-chart
         cd conjur-oss-helm-chart
     ```
   </details>

1. Run the demo scripts!

   ```sh-session
       cd examples/kubernetes-in-docker
       ./start
   ```

   That's all there is to it!

   The scripts will create a KinD cluster, install Conjur OSS, load
   Conjur security policy, and deploy several instances of the `Pet Store`
   applications that use Conjur Kubernetes authentication.

   If everything is successful, you should see the following message:

   ```sh-session
   ++++++++++++++++++++++++++++++++++++++++++++++++++++

   Deployment of Conjur and demo applications is complete!

   ++++++++++++++++++++++++++++++++++++++++++++++++++++
   ```

## Behind the Scenes: So What Did this Demo Just Do?

If you followed the steps in the previous section, you should now have:

- A local [Kubernetes-in-Docker (KinD)](https://github.com/kubernetes-sigs/kind)
  cluster that is running:
  - A [Conjur OSS](https://docs.conjur.org/) server, with a peristent
    Postgresql backend database, that has the
    [Conjur Kubernetes Authenticator](https://docs.conjur.org/Latest/en/Content/Operations/Services/k8s_auth.htm)
    enabled
  - Several instances of the
    [Pet Store](https://github.com/conjurdemos/pet-store-demo/) application
    that are using the following Conjur broker/clients to authenticate with
    Conjur and to access application-specific secrets from Conjur:
    - [Secretless Broker](https://github.com/cyberark/secretless-broker) sidecar
      container to manage the application's database connection
    - [Conjur Kubernetes Authenticator Client](https://github.com/cyberark/conjur-authn-k8s-client)
      sidecar container to provide the Conjur access token, and
      [Summon](https://github.com/cyberark/summon) to inject the application's
      database credentials into the application environment
    - [Conjur Kubernetes Authenticator Client](https://github.com/cyberark/conjur-authn-k8s-client)
      init container to provide the Conjur access token, and
      [Summon](https://github.com/cyberark/summon) to inject the application's
      database credentials into the application environment

Before we explore this setup further, it would help to discuss the
[Conjur Kubernetes Authenticator](https://docs.conjur.org/Latest/en/Content/Operations/Services/k8s_auth.htm)
(`authn-k8s`) and
[Conjur application identity](https://docs.conjur.org/Latest/en/Content/Integrations/Kubernetes_AppIdentity.htm?TocPath=Integrations%7COpenShift%252C%20Kubernetes%252C%20and%20GKE%7C_____2).

### Background: The Conjur Kubernetes Authenticator and Conjur Application Identity

The Conjur authentication broker/clients listed above are essentially
authentication proxies for the application. These broker/clients communicate
with the
[Conjur Kubernetes Authenticator](https://docs.conjur.org/Latest/en/Content/Operations/Services/k8s_auth.htm)
(a.k.a. `authn-k8s`) plugin running on the Conjur server to authenticate a
Kubernetes application.

The `authn-k8s` plugin makes use of several forms of 
[Conjur application identity](https://docs.conjur.org/Latest/en/Content/Integrations/Kubernetes_AppIdentity.htm?TocPath=Integrations%7COpenShift%252C%20Kubernetes%252C%20and%20GKE%7C_____2)
to positively identify the application. In the case of Kubernetes Conjur demo
scripts, the application identity that is used are the following
attributes of each application instance:
- Kubernetes Namespace name
- Kubernetes ServiceAccount name
- Kubernetes Deployment name
- Kubernetes Authenticator (sidecar or init) container name

If all of the above resource names match what has been specified in Conjur
policy (which is typically loaded into Conjur by a security administrator),
then the application is permitted to access secrets as dictated by that policy.

### Demo Script Workflow

Let's now take a high-level look at the workflow that the demo scripts
followed in creating your demo environment. The workflow can be categorized
into four phases:

- Platform Admin Tasks:
  - Create a local, containerized, Kubernetes cluster using
    [KinD](https://github.com/kubernetes-sigs/kind) Kubernetes cluster
  - Helm install Conjur OSS
- Security Admin Tasks:
  - Enable the
    [Conjur Kubernetes Authenticator](https://docs.conjur.org/Latest/en/Content/Operations/Services/k8s_auth.htm)
    (`authn-k8s`)
  - Load Conjur authentication and application-specific security policies
- Application Deployment:
  - Deploy instances of a simple "Pet Store" application using
    each of the following Conjur authentication broker/clients:
    - [Secretless Broker](https://github.com/cyberark/secretless-broker) sidecar container
    - [Conjur Kubernetes Authenticator Client](https://github.com/cyberark/conjur-authn-k8s-client)
      sidecar container
    - [Conjur Kubernetes Authenticator Client](https://github.com/cyberark/conjur-authn-k8s-client)
      init container
- Application Verification:
  - Poll each application's Kubernetes service, wait for a response.
    (A response indicates Kubernetes authentication was successful.)
  - Add a "pet" entry for each application
  - Read back "pet" entries for each application

### Exploring The Local KinD Cluster

The demo scripts use
[Kubernetes-in-Docker (KinD)](https://github.com/kubernetes-sigs/kind)
for creating a local, containerized, Kubernetes cluster on your local host
machine. With KinD, Kubernetes nodes are created as local Docker containers.
KinD supports multiple-node clusters, and can be run on Linux,
macOS, or Windows hosts (_NOTE: These demo scripts are not supported on
Windows environments._)

To view existing KinD clusters that are running on your host, run:

```sh-session
    $ kind get clusters
    kind
    $
```

To view Kubernetes namespaces that have been created on the `kind` cluster:

```sh-session
    $ kubectl get ns
    NAME                 STATUS   AGE
    app-test             Active   24m
    conjur-oss           Active   24m
    default              Active   24m
    kube-node-lease      Active   24m
    kube-public          Active   24m
    kube-system          Active   24m
    local-path-storage   Active   24m
    $
```
 
### Exploring the `conjur-oss` Namespace

This demonstration makes use of the
[Conjur OSS Helm Chart](https://github.com/cyberark/conjur-oss-helm-chart/tree/master/conjur-oss)
to install a Conjur cluster on the local KinD cluster.

#### Conjur OSS Pods

To view the Conjur OSS cluster pods that are created by the Helm chart, run:

```sh-session
    $ kubectl get pods -n conjur-oss -l release=conjur-oss
    NAME                          READY   STATUS    RESTARTS   AGE
    conjur-oss-5cb86bf558-vrr4r   2/2     Running   0          26m
    conjur-oss-postgres-0         1/1     Running   0          26m
    $
```

The Helm install of Conjur OSS creates a Conjur OSS master pod and
a Postgresql pod to serve as a backend database to persistently store
Conjur OSS policies and secrets.

The Conjur OSS master pod contains two containers:

```sh-session
    $ kubectl get pod -n conjur-oss -l app=conjur-oss -o jsonpath='{.items[*].spec.containers[*].name}'
    conjur-oss-nginx conjur-oss
    $
```

The `conjur-oss` container provides the Conjur OSS server functionality,
and the `conjur-oss-nginx` container terminates TLS for secure access to
the Conjur OSS service.

#### Kubernetes Authentication ClusterRole

The Conjur OSS Helm Chart includes the deployment of a
[Kubernetes ClusterRole](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-and-clusterrole)
resource. A Kubernetes `ClusterRole` contains rules that
enumerate a set of permissions to access various Kubernetes resources.

In this case, the Conjur OSS authentication `ClusterRole` is used to enumerate
permissions that may be granted to the Conjur Kubernetes Authenticator
*on a per-namespace basis* to allow the authenticator to authenticate
applications based upon
[Conjur application identity](https://docs.conjur.org/Latest/en/Content/Integrations/Kubernetes_AppIdentity.htm?TocPath=Integrations%7COpenShift%252C%20Kubernetes%252C%20and%20GKE%7C_____2).

Note that the permissions that are included in this `ClusterRole`
do not take effect until the `ClusterRole` is bound to the Conjur OSS
service account via a namespace-scoped `RoleBinding`, as described in the
[Demo Application RoleBinding](#demo-application-rolebinding) section below.

To view the Conjur OSS authentication ClusterRole, run:

```sh-session
    kubectl get clusterrole -n conjur-oss -l release=conjur-oss -o yaml
```

<details>
  <summary>Click to view sample output.</summary>

  ```
  kubectl get clusterrole -n conjur-oss -l release=conjur-oss -o yaml
  apiVersion: v1
  items:
  - apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      creationTimestamp: "2020-11-02T14:01:14Z"
      labels:
        app: conjur-oss
        app.kubernetes.io/name: conjur-oss
        chart: conjur-oss-2.0.1
        heritage: Helm
        release: conjur-oss
      managedFields:
      - apiVersion: rbac.authorization.k8s.io/v1beta1
        fieldsType: FieldsV1
        fieldsV1:
          f:metadata:
            f:labels:
              .: {}
              f:app: {}
              f:app.kubernetes.io/name: {}
              f:chart: {}
              f:heritage: {}
              f:release: {}
          f:rules: {}
        manager: Go-http-client
        operation: Update
        time: "2020-11-02T14:01:14Z"
      name: conjur-oss-conjur-authenticator
      resourceVersion: "103227"
      selfLink: /apis/rbac.authorization.k8s.io/v1/clusterroles/conjur-oss-conjur-authenticator
      uid: a319546d-784d-47fc-b5c1-5652e60c91d1
    rules:
    - apiGroups:
      - ""
      resources:
      - pods
      - serviceaccounts
      verbs:
      - get
      - list
    - apiGroups:
      - extensions
      resources:
      - deployments
      - replicasets
      verbs:
      - get
      - list
    - apiGroups:
      - apps
      resources:
      - deployments
      - statefulsets
      - replicasets
      verbs:
      - get
      - list
    - apiGroups:
      - ""
      resources:
      - pods/exec
      verbs:
      - create
      - get
  kind: List
  metadata:
    resourceVersion: ""
    selfLink: ""
  ```
</details>

#### Viewing Enabled Conjur Authenticator Plugins

Conjur OSS supports several industry-standard
[authentication types](https://docs.conjur.org/Latest/en/Content/Operations/Services/authentication-types.htm#SupportedAuthenticators).
Conjur can be configured to use on or a combination of authenticator types.

In addition to the default Conjur authenticator, these demo scripts enable
the Conjur
[Kubernetes Authenticator (`authn-k8s`)](https://docs.conjur.org/Latest/en/Content/Operations/Services/k8s_auth.htm?tocpath=Integrations%7C_____9#KubernetesAuthenticator) that authenticates
applications based upon
[Conjur Application Identity](https://docs.conjur.org/Latest/en/Content/Integrations/Kubernetes_AppIdentity.htm?TocPath=Integrations%7COpenShift%252C%20Kubernetes%252C%20and%20GKE%7C_____2).

To view the authenticators that are enabled for Conjur OSS, run:

```sh-session
    $ authn_secret=$(kubectl get secret -n conjur-oss | grep authenticators | awk '{print $1}')
    $ kubectl get secret -n conjur-oss "$authn_secret" --template={{.data.key}} | base64 -d && echo
    authn,authn-k8s/my-authenticator-id
    $
```

In this case, there are two authenticators enabled:
- `authn`: The default Conjur authenticator
- `authn-k8s/my-authenticator-id`: The Kubernetes authenticator is enabled
   for an authenticator ID of `my-authenticator-id`.

#### Conjur CLI Pod

For convenience, the demo scripts create a `conjur-cli` deployment in the
`conjur-oss` namespace. This makes it easy to run
[Conjur CLI](https://docs.conjur.org/latest/en/Content/Tools/CLI_Help.htm)
commands to configure the Conjur cluster:

```sh-session
    $ kubectl get pods -n conjur-oss -l app=conjur-cli
    NAME                          READY   STATUS    RESTARTS   AGE
    conjur-cli-6d895db49d-qs4pb   1/1     Running   0          59s
    $
```

To run
[Conjur CLI](https://docs.conjur.org/latest/en/Content/Tools/CLI_Help.htm)
commands, first initialized the Conjur CLI pod's connection with
Conjur as follows:

```
# Retrieve Conjur admin password
CONJUR_POD="$(kubectl get pods -n conjur-oss -l app=conjur-oss \
        -o jsonpath='{.items[0].metadata.name}')"
CONJUR_ACCOUNT="$(kubectl exec -n conjur-oss $CONJUR_POD -c conjur-oss \
        -- printenv \
        | grep CONJUR_ACCOUNT \
        | sed 's/.*=//')"
ADMIN_PASSWORD="$(kubectl exec -n conjur-oss $CONJUR_POD -c conjur-oss \
        -- conjurctl role retrieve-key $CONJUR_ACCOUNT:user:admin | tail -1)"

# Initialize the Conjur CLI pod's connection to Conjur
export CLI_POD="$(kubectl get pods -n conjur-oss -l app=conjur-cli \
        -o jsonpath='{.items[0].metadata.name}')"
CONJUR_URL="https://conjur-oss.conjur-oss.svc.cluster.local"
kubectl exec -n conjur-oss $CLI_POD \
        -- bash -c "yes yes | conjur init -a $CONJUR_ACCOUNT -u $CONJUR_URL"
kubectl exec -n conjur-oss $CLI_POD -- conjur authn login \
        -u admin -p $ADMIN_PASSWORD
```

And then create a `conjur` alias if your shell supports aliases:

```
# Create a 'conjur' command alias
alias conjur="kubectl exec -n conjur-oss $CLI_POD -- conjur"
```

Or export a `CONJUR_CMD` environment variable if your shell does not
support aliases:

```
# Create a 'conjur' command alias
export CONJUR_CMD="kubectl exec -n conjur-oss $CLI_POD -- conjur"
```

After that initial setup, Conjur commands can be executed using the `conjur`
command alias, if you've created one:

```sh-session
    $ conjur list variables | grep alice
      "myConjurAccount:user:alice",
    $
```

Or by using the `CONJUR_CMD` environment variable:

```sh-session
    $ $CONJUR_CMD list variables | grep alice
      "myConjurAccount:user:alice",
    $
```
    
### Viewing Rendered Conjur-OSS Security Policy

The demo scripts render several YAML manifest files that define
application-specific Conjur security policy. These YAML manifest files
are loaded into the Conjur OSS server to configure which applications
are permitted to access secrets from Conjur.

**After the demo scripts have been run**, it is possible to view the
rendered Conjur security manifest files. These files can be viewed
in the `temp/kubernetes-conjur-demo/policy/generated` subdirectory:

  - app-test.app-identity.yml
  - app-test.cluster-authn-svc.yml
  - app-test.project-authn.yml

*_NOTE: These rendered Conjur policy manifests can be found only after
running the demo scripts._*

For example, let's look at the entry in `app-test.project-authn.yml`
that defines the Conjur application identity for the `test-app-secretless`
application that is deployed by the demo scripts:

```
    - !host
      id: test-app-secretless
      annotations:
        authn-k8s/namespace: app-test
        authn-k8s/service-account: test-app-secretless
        authn-k8s/deployment: test-app-secretless
        authn-k8s/authentication-container-name: secretless
        kubernetes: "true"
```

In this host definition, the annotations specify that in order for the
Secretless Broker to successfully authenticate the `test-app-secretless`
deployment, all of the following need to be true:

- Application is running in the `app-test` namespace
- Application is using the `test-app-secretless` ServiceAccount
- Application's deployment name is `test-app-secretless`
- Application pod contains a container named `secretless`

### Exploring the Demo Application `app-test` Namespace

#### Demo Application Pods

You can view the demo application pods that are created by the demo script
by running:

```
        kubectl get pods -n app-test
```

<details>
  <summary>Click to expand sample output.</summary>

  ```
  $ kubectl get pods -n app-test
  NAME                                                              READY   STATUS    RESTARTS   AGE
  secretless-pg-0                                                   1/1     Running   0          14h
  summon-init-pg-0                                                  1/1     Running   0          14h
  summon-sidecar-pg-0                                               1/1     Running   0          14h
  test-app-secretless-989486bc7-dfm9z                               2/2     Running   1          14h
  test-app-summon-init-7f9c8f4598-6djn5                             1/1     Running   0          14h
  test-app-summon-sidecar-5dc96cd94c-pdflp                          2/2     Running   0          14h
  test-app-with-host-outside-apps-branch-summon-init-74987c45jrp6   1/1     Running   0          14h
  test-curl
  $
  ```
</details>

The pods displayed will include:
- Test application pods
- Test application database pods
- A `test-curl` pod used to access applications from within the KinD cluster

#### Demo Application RoleBinding

The demo scripts create a namespace-scoped Kubernetes 
[RoleBinding](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#rolebinding-and-clusterrolebinding)
named `test-app-conjur-authenticator-role-binding-conjur-oss` in the
`app-test` namespace. This RoleBinding is used to grant access permissions
that were defined in the `conjur-oss-conjur-authenticator` ClusterRole
(see the
[Kubernetes Authentication ClusterRole](#kubernetes-authentication-clusterRole)
section above).

RoleBindings are namespace-scoped; that is, they access permissions that are
granted apply only to resources that are in the namespace in which the
RoleBinding exists (in this case, the `app-test namespace).

To view the demo application RoleBinding, use:

```
    kubectl get rolebinding -n app-test -o yaml
```

<details>
  <summary>Click to expand sample output.</summary>

  ```sh-session
  $ kubectl get rolebinding -n app-test -o yaml
  apiVersion: v1
  items:
  - apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      creationTimestamp: "2020-11-02T19:34:58Z"
      managedFields:
      - apiVersion: rbac.authorization.k8s.io/v1
        fieldsType: FieldsV1
        fieldsV1:
          f:roleRef:
            f:apiGroup: {}
            f:kind: {}
            f:name: {}
          f:subjects: {}
        manager: kubectl
        operation: Update
        time: "2020-11-02T19:34:58Z"
      name: test-app-conjur-authenticator-role-binding-conjur-oss
      namespace: app-test
      resourceVersion: "1479"
      selfLink: /apis/rbac.authorization.k8s.io/v1/namespaces/app-test/rolebindings/test-app-conjur-authenticator-role-binding-conjur-oss
      uid: 7b056eb2-876c-4486-b784-3a847506bf62
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: conjur-oss-conjur-authenticator
    subjects:
    - kind: ServiceAccount
      name: conjur-oss
      namespace: conjur-oss
  kind: List
  metadata:
    resourceVersion: ""
    selfLink: ""
  ```
</details>

## Customizable Demo Settings

The demo scripts provide customizable environment variable settings
to allow the scripts to be run in different situations. The customizable
settings can be viewed in the `customize.env` file (where they will appear
commented out). The default values of these customizable settings will
work as-is in most cases, but there may be special situations that require
modifications to these settings.

### How to Modify Customizable Demo Settings

There are two ways to modify the customizable demo settings:

1. Modify settings directly in the `customize.env` file and run the
   `start` script without arguments as shown earlier, i.e.:

   ```
   ./start
   ```

2. Create a copy of `customize.env` file and make modifications to the new
   file. Then when starting the demo with the `start` script, use the
   `-c` argument to have it use your customized settings file, e.g.:

   ```
   ./start -c my_customize.env
   ```

### Example: Configuring a Docker Registry

By default, the Kubernetes Conjur Demo scripts will create a local, insecure
Docker registry to which the scripts can build and push demo images. When
pods are created in the KinD cluster, then Kubernetes will pull images
from that local, insecure registry.

If you would prefer to use a public Docker registry (e.g. DockerHub),
you can uncomment out and modify the following lines in `customize.env`: 

```
#export USE_DOCKER_LOCAL_REGISTRY=true
#export DOCKER_REGISTRY_URL="docker.io"
#export DOCKER_REGISTRY_PATH="<your-dockerhub-org-or-username>"
#export DOCKER_USERNAME="<your-dockerhub-username>"
#export DOCKER_PASSWORD="<your-dockerhub-password>"
#export DOCKER_EMAIL="<your-dockerhub-email>"
```

For example, if you are using a personal DockerHub account, the environment
settings might look something like this:

```
export USE_DOCKER_LOCAL_REGISTRY=false
export DOCKER_REGISTRY_URL="docker.io"
export DOCKER_REGISTRY_PATH="firstnamelastname"
export DOCKER_USERNAME="firstnamelastname"
export DOCKER_PASSWORD="GreatGooglyMoogly"
export DOCKER_EMAIL="firstname.lastname@example.com"
```

## Enabling Conjur Debug Logging

If for some reason the scripts fail to deploy applications, or fail to
successfully retrieve Conjur secrets, it may help to enable debug logs
in the Conjur server, and then using `kubectl logs ...` to display
Conjur logs in order to troubleshoot the problem.

To enable Conjur debug logging, use Helm upgrade as follows:

```sh-session
CONJUR_NAMESPACE=conjur-oss
HELM_RELEASE=conjur-oss
helm upgrade \
     -n "$CONJUR_NAMESPACE" \
     --reuse-values \
     --set logLevel=debug \
     "$HELM_RELEASE" \
     ./conjur-oss
```

The Conjur servers logs can then be displayed as follows:

```sh-session
conjur_container="conjur-oss"
pod_name=$(kubectl get pods \
          -n "$CONJUR_NAMESPACE" \
          -l "app=conjur-oss,release=$HELM_RELEASE" \
          -o jsonpath="{.items[0].metadata.name}")
kubectl logs -n "$CONJUR_NAMESPACE" "$pod_name" "$conjur_container"
```

## Cleaning Up

When you are done with the Kubernetes Conjur Demo, you can clean up
the demo setup as described in the following sections.

**_NOTE: If you are cleaning up all resources associated with the demo,
you can skip down to
[Deleting the KinD Cluster](#deleting-the-kind-cluster)._**

### Deleting the Kubernetes Conjur Demo Applications

The Kubernetes Conjur Demo application deployments and their related
Kubernetes resources can be cleaned up by deleting the `app-test` namespace:

```sh-session
kubectl delete ns app-test
```

### Uninstalling Conjur OSS via Helm Delete

To remove the Conjur OSS deployment from your KinD cluster, run the following:

```sh-session
CONJUR_NAMESPACE=conjur-oss
HELM_RELEASE=conjur-oss
helm delete -n "$CONJUR_NAMESPACE" "$HELM_RELEASE"
```

### Deleting the KinD Cluster

**_NOTE: If you are deleting the KinD cluster, there is no need to perform
the cleanup steps from the previous two sections._**

To delete the KinD cluster from your local host, run the following:

```sh-session
kind delete cluster
```
