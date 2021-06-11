#!/bin/bash

export KUBECONFIG=/home/ocp/cluster_mgnt_roles/kubeconfig.ostest
if [[ "$(oc project -q)" -ne "opentack" ]]; then
    oc project openstack
fi

pushd /root/osp-director-dev-tools/ansible/
make openstack
popd
sleep 5
oc get pods

date
ls -ld /root/ostest-working/yamls/playbook_generator/

echo -e "\nIs generate-playbooks-* still running? (If yes, then wait)\n"
echo "oc get pods"
