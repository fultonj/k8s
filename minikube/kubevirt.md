# Kubevirt 

From https://kubevirt.io/quickstart_minikube

## Install

Confirm nested virtualization
`cat /sys/module/kvm_intel/parameters/nested`

Set version variable (https://github.com/kubevirt/kubevirt/tags)
```
export VERSION="v0.41.0"
```
Deploy the KubeVirt operator:
```
kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-operator.yaml
```
Deploy KubeVirt CRD
```
kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-cr.yaml
```

## Check Status

Confirm kubevirt is deployed
```
kubectl get kubevirt.kubevirt.io/kubevirt -n kubevirt -o=jsonpath="{.status.phase}"
```
View all resources in kubevirt namespace:
```
kubectl get all -n kubevirt
```

## virtctl

KubeVirt provides an additional binary called virtctl for quick access to the serial and graphical ports of a VM and also handle start/stop operations.

```
VERSION=$(kubectl get kubevirt.kubevirt.io/kubevirt -n kubevirt -o=jsonpath="{.status.observedKubeVirtVersion}")
ARCH=$(uname -s | tr A-Z a-z)-$(uname -m | sed 's/x86_64/amd64/') || windows-amd64.exe
curl -L -o virtctl https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/virtctl-${VERSION}-${ARCH}
mv virtctl ~/bin/
chmod 755 ~/bin/virtctl 
```

## Create a VM

From https://kubevirt.io/labs/kubernetes/lab1

Define a VM
```
kubectl apply -f https://raw.githubusercontent.com/kubevirt/kubevirt.github.io/master/labs/manifests/vm.yaml
```

View all VMs
```
kubectl get vms
```

Get details on a VM
```
kubectl get vms -o yaml testvm
```

Determine if the VM is running:
```
kubectl get vms -o json | jq .items[0].spec.running
```

Start the VM
```
virtctl start testvm
```

Console into the VM
```
virtctl console testvm
```

Stop the VM
```
virtctl stop testvm
```

Delete the VM
```
kubectl delete vm testvm
```
