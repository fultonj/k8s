#!/bin/bash
set -e
export KUBECONFIG=/home/ocp/cluster_mgnt_roles/kubeconfig.ostest
if [[ "$(oc project -q)" -ne "opentack" ]]; then
    oc project openstack
fi

pushd /root/osp-director-dev-tools/ansible/
make openstack_cleanup
popd
