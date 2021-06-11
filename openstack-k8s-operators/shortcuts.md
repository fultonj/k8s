# Shortcuts for openstack-k8s-operators beginners

## Build Env on Hypervisor
Use [docs on openstack-k8s/ansible](https://github.com/openstack-k8s-operators/osp-director-dev-tools/tree/master/ansible#openstack-k8sansible)
to deploy OCP, CNV, Metal3, and the OpenStack operator.

Note the [Makefile](https://github.com/openstack-k8s-operators/osp-director-dev-tools/blob/master/ansible/Makefile).


## Web Interface
```
username: kubeadmin
password: `cat /home/ocp/cluster_mgnt_roles/kubeadmin-password.ostest`
```


## Authenticate
```
export KUBECONFIG=/home/ocp/cluster_mgnt_roles/kubeconfig.ostest
```

## Deploy Overcloud

### Use Heat and config-download to generate playbooks

```
make openstack
```
Make sure `oc get pods -n openstack` shows an `openstackclient` pod.

### Genereate the playbooks inside the openstackclient pod
```
oc rsh openstackclient
cd /home/cloud-admin/
./tripleo-deploy.sh -a 
```
To deploy the overcloud you used to need to run the above
and then run `./tripleo-deploy.sh -p` but Ansible now does
this for you.

See also the
[openstack-k8s-operators readme section on deploying OpenStack](https://github.com/openstack-k8s-operators/osp-director-operator#deploying-openstack-once-you-have-the-osp-director-operator-installed).

#### Read the Genereated playbooks during the deployment
```
oc rsh openstackclient
cd /home/cloud-admin/playbooks/tripleo-ansible
```

## Connect to openstack client to create an instance after deployment
```
oc -n openstack rsh openstackclient
egrep "auth_url|password" /home/cloud-admin/.config/openstack/clouds.yaml
```

If the deployment succeeded then the above file should be present.

Substitute the PASS and URL below
```
export OS_PASSWORD=$PASS
export OS_AUTH_URL=$URL
export OS_AUTH_TYPE=password
export OS_USERNAME=admin
export OS_PROJECT_NAME=admin
export OS_PROJECT_DOMAIN_NAME='Default'
```
Run openstack commands as usual
```
openstack endpoint list -c "Service Name" -f value

openstack volume create --size 1 test-volume
openstack volume list
```
Use commands like [validate.sh](https://github.com/fultonj/xena/blob/main/standard/validate.sh).


## Connect to CNV controller
```
kubectl get vms
virtctl console controller-0
username: root
password: 12345678
```

## Connect to Metal3 compute
```
oc get osnet ctlplane -o json | jq .status.roleReservations.ComputeHCI 
oc rsh openstackclient
ssh cloud-admin@192.168.25.101
```
Use the first command to confirm the IP address (e.g. 192.168.25.101)


## Re-deploy overcloud
```
make openstack_cleanup
make openstack
```

Then see "Deploy Overcloud" above.

See the [Makefile](https://github.com/openstack-k8s-operators/osp-director-dev-tools/blob/master/ansible/Makefile) for details on what these commands do.

## Debugging

### Recreate playbooks
```
oc delete osplaybookgenerator --all
make playbook_generator
```
You should see `/root/ostest-working/yamls/playbook_generator/`
has a recent timestamp.

### Debugging Playbook Generator
```
GEN=$(oc get pods | grep generate | awk {'print $1'})
for P in $GEN; do echo $P; oc logs -f $P; done
```
You could genereate the playbook manually only for debug purposes:
```
oc get pods | grep playbooks
oc rsh generate-playbooks-default-trcsr
cd /home/cloud-admin/
bash create-playbooks.sh
```
The above shouldn't be necessary because creating the container 
is sufficient to generate the playbooks.

### Checking the Contents of the Heat Templates

Custom templates:
```
ls /root/ostest-working/yamls/tripleo_deploy/
cat /root/ostest-working/yamls/tripleo_deploy/storage-backend.yaml
```
Network config and roles data YAMLs:
```
ls /root/ostest-working/yamls/tripleo_deploy_tarball/
cat /root/ostest-working/yamls/tripleo_deploy_tarball/roles_data.yaml
```
If the above was not produced you can check what got into the config
[ConfigMap](https://kubernetes.io/docs/concepts/configuration/configmap).
```
oc get cm tripleo-deploy-config-custom -o yaml
oc get cm tripleo-deploy-config-custom -o json | jq .data
```
Check the network config and roles data YAMLs:
```
oc get cm tripleo-tarball-config -o yaml
oc get cm tripleo-tarball-config -o json | jq .binaryData > /tmp/test
vi /tmp/test
```
At this point you'll need to edit /tmp/test to extract only the
payload. I.e. remove the json and the key and keep only the value.
You can then do the following to extract the tarball.
```
cat /tmp/test |base64 -d > /tmp/test.tgz
file /tmp/test.tgz
tar tfvz /tmp/test.tgz
```
