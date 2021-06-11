#!/bin/bash

set -e

if [[ "$(oc project -q)" -ne "opentack" ]]; then
    oc project openstack
fi

if [[ ! -e /tmp/cirros-0.4.0-x86_64-disk.raw ]]; then
    curl -L http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img -o /tmp/cirros-0.4.0-x86_64-disk.img
    qemu-img convert -f qcow2 -O raw /tmp/cirros-0.4.0-x86_64-disk.img /tmp/cirros-0.4.0-x86_64-disk.raw
fi
oc cp /tmp/cirros-0.4.0-x86_64-disk.raw openstackclient:/tmp/cirros.raw


OC="oc exec --stdin --tty openstackclient -- "
URL=$($OC egrep auth_url /home/cloud-admin/tripleo-deploy/clouds.yaml | \
          awk {'print $2'} | sed 's/ *$//') 
PASS=$($OC egrep password /home/cloud-admin/tripleo-deploy/clouds.yaml | \
           awk {'print $2'} | sed 's/ *$//')

cat <<EOF > /tmp/overcloudrc
alias ls='ls -F'
alias ll='ls -lhtr'
export OS_AUTH_TYPE=password
export OS_PASSWORD=$PASS
export OS_AUTH_URL=$URL
export OS_USERNAME=admin
export OS_PROJECT_NAME=admin
export OS_PROJECT_DOMAIN_NAME='Default'
EOF

oc cp /tmp/overcloudrc openstackclient:/tmp/overcloudrc

cat <<EOF > /tmp/test.sh
openstack endpoint list -c "Service Name" -f value

openstack volume create --size 1 test-volume
openstack volume list

openstack image create cirros --disk-format=raw --container-format=bare < /tmp/cirros.raw
openstack image list 

DEMO_CIDR="172.16.66.0/24"
openstack network create private_network
NETID=\$(openstack network list | awk "/private_network/ { print \\\$2 }")
openstack subnet create --network private_network --subnet-range \${DEMO_CIDR} private_subnet
openstack flavor create --ram 512 --disk 1 --ephemeral 0 --vcpus 1 --public m1.tiny
openstack keypair create demokp > ~/demokp.pem 
openstack server create --flavor m1.tiny --image cirros --key-name demokp inst1 --nic net-id=\$NETID

EOF

oc cp /tmp/test.sh openstackclient:/tmp/test.sh

echo "oc -n openstack rsh openstackclient"
echo "cat /tmp/overcloudrc"
echo "cat /tmp/test.sh"
