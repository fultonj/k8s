# Hello World

## Create
Create echoserver deployment
```
kubectl create deployment hello-minikube --image=k8s.gcr.io/echoserver:1.4
```
Expose the service
```
kubectl expose deployment hello-minikube --type=NodePort --port=8080
```
Confirm the services are running
```
kubectl get services hello-minikube
```
Forward port 7070 on the localhost to the app
```
kubectl port-forward service/hello-minikube 7080:8080
```
Point browser at: http://localhost:7080/


## Remove

Delete service
```
kubectl delete service hello-minikube
```
Delete deployment
```
kubectl delete deployment hello-minikube
```
