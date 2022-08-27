# Operator SDK Notes

My notes from the Go Operator Tutorial:

- https://sdk.operatorframework.io/docs/building-operators/golang/tutorial/

<!--
https://docs.openshift.com/container-platform/4.11/operators/operator_sdk/golang/osdk-golang-tutorial.html
-->

## Prerequisites

I'm using CRC on RHEL8.5. I installed the operator sdk by following 
[this](https://docs.openshift.com/container-platform/4.11/operators/operator_sdk/osdk-installing-cli.html#osdk-installing-cli)].
I ran the following.

```
eval $(crc oc-env)
export GO111MODULE=on
oc login -u kubeadmin -p 12345678 https://api.crc.testing:6443
```

### Init

The tutorial has you run the folowing:

```
mkdir -p $HOME/projects/memcached-operator
cd $HOME/projects/memcached-operator
operator-sdk init --domain example.com --repo github.com/example/memcached-operator
```

Do not worry that `github.com/example/memcached-operator` does not
actually exist on github. Also you don't need to create a variation
like https://github.com/fultonj/memcached-operator via the github UI
that gets populated later. Just copy/paste verbatim.

The `operator-sdk init` command creates a lot of stuff.

```
[fultonj@osp-storage-01 memcached-operator]$ tree
.
├── config
│   ├── default
│   │   ├── kustomization.yaml
│   │   ├── manager_auth_proxy_patch.yaml
│   │   └── manager_config_patch.yaml
│   ├── manager
│   │   ├── controller_manager_config.yaml
│   │   ├── kustomization.yaml
│   │   └── manager.yaml
│   ├── manifests
│   │   └── kustomization.yaml
│   ├── prometheus
│   │   ├── kustomization.yaml
│   │   └── monitor.yaml
│   ├── rbac
│   │   ├── auth_proxy_client_clusterrole.yaml
│   │   ├── auth_proxy_role_binding.yaml
│   │   ├── auth_proxy_role.yaml
│   │   ├── auth_proxy_service.yaml
│   │   ├── kustomization.yaml
│   │   ├── leader_election_role_binding.yaml
│   │   ├── leader_election_role.yaml
│   │   ├── role_binding.yaml
│   │   └── service_account.yaml
│   └── scorecard
│       ├── bases
│       │   └── config.yaml
│       ├── kustomization.yaml
│       └── patches
│           ├── basic.config.yaml
│           └── olm.config.yaml
├── Dockerfile
├── go.mod
├── go.sum
├── hack
│   └── boilerplate.go.txt
├── main.go
├── Makefile
├── PROJECT
└── README.md

10 directories, 30 files
[fultonj@osp-storage-01 memcached-operator]$ 
```

2000 lines of it. 

```
[fultonj@osp-storage-01 memcached-operator]$ find . | xargs wc -l 2> /dev/null
      0 .
      0 ./config
      0 ./config/rbac
     15 ./config/rbac/auth_proxy_service.yaml
      9 ./config/rbac/auth_proxy_client_clusterrole.yaml
     12 ./config/rbac/role_binding.yaml
     37 ./config/rbac/leader_election_role.yaml
      5 ./config/rbac/service_account.yaml
     12 ./config/rbac/auth_proxy_role_binding.yaml
     12 ./config/rbac/leader_election_role_binding.yaml
     18 ./config/rbac/kustomization.yaml
     17 ./config/rbac/auth_proxy_role.yaml
      0 ./config/manager
     10 ./config/manager/kustomization.yaml
     21 ./config/manager/controller_manager_config.yaml
     71 ./config/manager/manager.yaml
      0 ./config/default
     40 ./config/default/manager_auth_proxy_patch.yaml
     20 ./config/default/manager_config_patch.yaml
     74 ./config/default/kustomization.yaml
      0 ./config/prometheus
     20 ./config/prometheus/monitor.yaml
      2 ./config/prometheus/kustomization.yaml
      0 ./config/manifests
     27 ./config/manifests/kustomization.yaml
      0 ./config/scorecard
      0 ./config/scorecard/bases
      7 ./config/scorecard/bases/config.yaml
      0 ./config/scorecard/patches
     10 ./config/scorecard/patches/basic.config.yaml
     50 ./config/scorecard/patches/olm.config.yaml
     16 ./config/scorecard/kustomization.yaml
      0 ./hack
     14 ./hack/boilerplate.go.txt
    104 ./main.go
     79 ./go.mod
     25 ./.gitignore
    236 ./Makefile
     27 ./Dockerfile
      4 ./.dockerignore
     94 ./README.md
    963 ./go.sum
      9 ./PROJECT
   2060 total
[fultonj@osp-storage-01 memcached-operator]$ 
```

Read about:
- PROJECT file
- Manager in main.go

Also read about the following which are not in scope for my current
project plans:

- Namespaces: n=1, 1<n<all, all
- multigroup APIs

### api

I then ran this:

```
operator-sdk create api \
    --group=cache \
    --version=v1 \
    --kind=Memcached
```

This adds about 500 lines of code provided you 
omit the 20M controller-gen binary it adds.

```
[fultonj@osp-storage-01 memcached-operator]$ find . | grep -v controller-gen |  xargs wc -l 2> /dev/null
      0 .
      0 ./config
      0 ./config/rbac
     15 ./config/rbac/auth_proxy_service.yaml
      9 ./config/rbac/auth_proxy_client_clusterrole.yaml
     12 ./config/rbac/role_binding.yaml
     37 ./config/rbac/leader_election_role.yaml
      5 ./config/rbac/service_account.yaml
     12 ./config/rbac/auth_proxy_role_binding.yaml
     12 ./config/rbac/leader_election_role_binding.yaml
     18 ./config/rbac/kustomization.yaml
     17 ./config/rbac/auth_proxy_role.yaml
     24 ./config/rbac/memcached_editor_role.yaml
     20 ./config/rbac/memcached_viewer_role.yaml
      0 ./config/manager
     10 ./config/manager/kustomization.yaml
     21 ./config/manager/controller_manager_config.yaml
     71 ./config/manager/manager.yaml
      0 ./config/default
     40 ./config/default/manager_auth_proxy_patch.yaml
     20 ./config/default/manager_config_patch.yaml
     74 ./config/default/kustomization.yaml
      0 ./config/prometheus
     20 ./config/prometheus/monitor.yaml
      2 ./config/prometheus/kustomization.yaml
      0 ./config/manifests
     27 ./config/manifests/kustomization.yaml
      0 ./config/scorecard
      0 ./config/scorecard/bases
      7 ./config/scorecard/bases/config.yaml
      0 ./config/scorecard/patches
     10 ./config/scorecard/patches/basic.config.yaml
     50 ./config/scorecard/patches/olm.config.yaml
     16 ./config/scorecard/kustomization.yaml
      0 ./config/crd
     21 ./config/crd/kustomization.yaml
     19 ./config/crd/kustomizeconfig.yaml
      0 ./config/crd/patches
     16 ./config/crd/patches/webhook_in_memcacheds.yaml
      7 ./config/crd/patches/cainjection_in_memcacheds.yaml
      0 ./config/samples
      6 ./config/samples/cache_v1_memcached.yaml
      4 ./config/samples/kustomization.yaml
      0 ./hack
     14 ./hack/boilerplate.go.txt
    115 ./main.go
     83 ./go.mod
     25 ./.gitignore
    236 ./Makefile
     27 ./Dockerfile
      4 ./.dockerignore
     94 ./README.md
    975 ./go.sum
     19 ./PROJECT
      0 ./api
      0 ./api/v1
     64 ./api/v1/memcached_types.go
     36 ./api/v1/groupversion_info.go
    115 ./api/v1/zz_generated.deepcopy.go
      0 ./controllers
     82 ./controllers/suite_test.go
     62 ./controllers/memcached_controller.go
      0 ./bin
   2573 total
[fultonj@osp-storage-01 memcached-operator]$ 
```

New subdirectories:
- TLD: added `api` and `controllers` directories
- config: addded `crc` and `samples` directories

```
[fultonj@osp-storage-01 memcached-operator]$ tree
.
├── api
│   └── v1
│       ├── groupversion_info.go
│       ├── memcached_types.go
│       └── zz_generated.deepcopy.go
├── bin
│   └── controller-gen
├── config
│   ├── crd
│   │   ├── kustomization.yaml
│   │   ├── kustomizeconfig.yaml
│   │   └── patches
│   │       ├── cainjection_in_memcacheds.yaml
│   │       └── webhook_in_memcacheds.yaml
│   ├── default
│   │   ├── kustomization.yaml
│   │   ├── manager_auth_proxy_patch.yaml
│   │   └── manager_config_patch.yaml
│   ├── manager
│   │   ├── controller_manager_config.yaml
│   │   ├── kustomization.yaml
│   │   └── manager.yaml
│   ├── manifests
│   │   └── kustomization.yaml
│   ├── prometheus
│   │   ├── kustomization.yaml
│   │   └── monitor.yaml
│   ├── rbac
│   │   ├── auth_proxy_client_clusterrole.yaml
│   │   ├── auth_proxy_role_binding.yaml
│   │   ├── auth_proxy_role.yaml
│   │   ├── auth_proxy_service.yaml
│   │   ├── kustomization.yaml
│   │   ├── leader_election_role_binding.yaml
│   │   ├── leader_election_role.yaml
│   │   ├── memcached_editor_role.yaml
│   │   ├── memcached_viewer_role.yaml
│   │   ├── role_binding.yaml
│   │   └── service_account.yaml
│   ├── samples
│   │   ├── cache_v1_246603memcached.yaml
│   │   └── kustomization.yaml
│   └── scorecard
│       ├── bases
│       │   └── config.yaml
│       ├── kustomization.yaml
│       └── patches
│           ├── basic.config.yaml
│           └── olm.config.yaml
├── controllers
│   ├── memcached_controller.go
│   └── suite_test.go
├── Dockerfile
├── go.mod
├── go.sum
├── hack
│   └── boilerplate.go.txt
├── main.go
├── Makefile
├── PROJECT
└── README.md

17 directories, 44 files
[fultonj@osp-storage-01 memcached-operator]$ 
```

Added `size` and `nodes` api/v1alpha1/memcached_types.go.
Ran `make generate` and then `make manifests` to trigger
`controller-gen`.

### Implement the Controller

Replace `memcached-operator/controllers/memcached_controller.go`
with their example. From what I read this seems to control the
main reconciliation loop (for each CRD).

### Running the Operator

As
[described](https://sdk.operatorframework.io/docs/building-operators/golang/tutorial/#run-the-operator)

Replace the controller created by the SDK:

```
[fultonj@osp-storage-01 memcached-operator]$ wc -l controllers/memcached_controller.go
62 controllers/memcached_controller.go
[fultonj@osp-storage-01 memcached-operator]$
```
with their controller. In my case I curl it in:
```
[fultonj@osp-storage-01 memcached-operator]$ curl https://raw.githubusercontent.com/operator-framework/operator-sdk/latest/testdata/go/v3/memcached-operator/controllers/memcached_controller.go -o controllers/memcached_controller.go 
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  9356  100  9356    0     0   172k      0 --:--:-- --:--:-- --:--:--  172k
[fultonj@osp-storage-01 memcached-operator]$ wc -l controllers/memcached_controller.go 
236 controllers/memcached_controller.go
[fultonj@osp-storage-01 memcached-operator]$
```

I was then able to run it:

```
[fultonj@osp-storage-01 memcached-operator]$ make deploy
/home/fultonj/projects/memcached-operator/bin/controller-gen rbac:roleName=manager-role crd webhook paths="./..." output:crd:artifacts:config=config/crd/bases
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash -s -- 3.8.7 /home/fultonj/projects/memcached-operator/bin
{Version:kustomize/v3.8.7 GitCommit:ad092cc7a91c07fdf63a2e4b7f13fa588a39af4f BuildDate:2020-11-11T23:14:14Z GoOs:linux GoArch:amd64}
kustomize installed to /home/fultonj/projects/memcached-operator/bin/kustomize
cd config/manager && /home/fultonj/projects/memcached-operator/bin/kustomize edit set image controller=controller:latest
/home/fultonj/projects/memcached-operator/bin/kustomize build config/default | kubectl apply -f -
namespace/memcached-operator-system created
customresourcedefinition.apiextensions.k8s.io/memcacheds.cache.example.com created
serviceaccount/memcached-operator-controller-manager created
role.rbac.authorization.k8s.io/memcached-operator-leader-election-role created
clusterrole.rbac.authorization.k8s.io/memcached-operator-manager-role created
clusterrole.rbac.authorization.k8s.io/memcached-operator-metrics-reader created
clusterrole.rbac.authorization.k8s.io/memcached-operator-proxy-role created
rolebinding.rbac.authorization.k8s.io/memcached-operator-leader-election-rolebinding created
clusterrolebinding.rbac.authorization.k8s.io/memcached-operator-manager-rolebinding created
clusterrolebinding.rbac.authorization.k8s.io/memcached-operator-proxy-rolebinding created
configmap/memcached-operator-manager-config created
service/memcached-operator-controller-manager-metrics-service created
deployment.apps/memcached-operator-controller-manager created
[fultonj@osp-storage-01 memcached-operator]$
```

And see that it is running:

```
[fultonj@osp-storage-01 memcached-operator]$ kubectl get deployment -n memcached-operator-system
NAME                                    READY   UP-TO-DATE   AVAILABLE   AGE
memcached-operator-controller-manager   0/1     1            0           35s
[fultonj@osp-storage-01 memcached-operator]$
```

Looks like it coulnd't pull image though.

```
[fultonj@osp-storage-01 memcached-operator]$ oc get pods -A| grep mem
memcached-operator-system                    memcached-operator-controller-manager-d569f8856-9gbdz             1/2     ImagePullBackOff   0            24m
[fultonj@osp-storage-01 memcached-operator]$ 
```


### OLM

Installing the OLM with the SDK failed.

```
[fultonj@osp-storage-01 memcached-operator]$ operator-sdk olm install
I0827 19:56:29.744425 3322847 request.go:601] Waited for 1.035932293s due to client-side throttling, not priority and fairness, request: GET:https://api.crc.testing:6443/apis/network.openshift.io/v1?timeout=32s
INFO[0002] Fetching CRDs for version "latest"           
INFO[0002] Fetching resources for resolved version "latest" 
FATA[0002] Failed to install OLM version "latest": detected existing OLM resources: OLM must be completely uninstalled before installation 
[fultonj@osp-storage-01 memcached-operator]$ 
```

Maybe this is becuse I'm already using an OLM for from
opestack-k8s-operators? I was not 

```
[fultonj@osp-storage-01 memcached-operator]$ operator-sdk olm status
I0827 20:00:56.560365 3324212 request.go:601] Waited for 1.043764939s due to client-side throttling, not priority and fairness, request: GET:https://api.crc.testing:6443/apis/build.openshift.io/v1?timeout=32s
FATA[0002] Failed to get OLM status: error getting installed OLM version (set --version to override the default version): no existing installation found 
[fultonj@osp-storage-01 memcached-operator]$ 
```

## Todo

- OLM
- Create a CR
- Update the size
- Clean Up
