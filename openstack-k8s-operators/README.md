# Scripts/Notes to help me use openstack-k8s-operators

I use
[osp-director-dev-tools](https://github.com/openstack-k8s-operators/osp-director-dev-tools)
to install the 
[osp-director-operator](https://github.com/openstack-k8s-operators/osp-director-operator)
and its dependencies with Ceph.

This directory has scripts and [shortcut notes](shortcuts.md) to
help me work in that environment.

## Overcloud Deploy Cycle
- Modify the [jinja2](https://github.com/openstack-k8s-operators/osp-director-dev-tools/tree/master/ansible/templates/osp) that creates THT
- [playbooks.sh](playbooks.sh): have heat/config-download genereate playbooks
- [deploy.sh](deploy.sh): deploy overcloud
- [validate.sh](validate.sh): confirm that keystone, glance, cinder, and nova work
- [undeploy.sh](undeploy.sh): undeploy overcloud to start the cycle again

