#!/bin/bash

export KUBECONFIG=/home/ocp/cluster_mgnt_roles/kubeconfig.ostest
if [[ "$(oc project -q)" -ne "opentack" ]]; then
    oc project openstack
fi

if [[ $(oc get pods | grep playbooks | wc -l) -gt 0 ]]; then
    echo "playbooks pod needs more time"
    exit 0
fi

OC="oc exec --stdin --tty openstackclient -- "
$OC /home/cloud-admin/tripleo-deploy.sh -a
$OC /home/cloud-admin/tripleo-deploy.sh -p
