# Minikube Notes

As per https://minikube.sigs.k8s.io/docs/start Tested on Fedora33

## Install
```
curl https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm -o ~/rpm/minikube-latest.x86_64.rpm
sudo dnf install -y ~/rpm/minikube-latest.x86_64.rpm
```

## Start
```
minikube start --driver=kvm2
kubectl get pods -A
```

## Stop
```
minikube stop
```

## Uninstall
```
minikube delete
```
