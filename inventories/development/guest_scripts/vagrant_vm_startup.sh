#!/usr/bin/env bash

# vagrant_vm_startup.sh
#
# This script is executed on each vagrant test VM when they are provisioned.
# It sets up the VM so that it is ready for the ansible script to be run.
#
# Note that certain steps in setup_vagrant_test_environment.sh need to be
# performed before the VMs can be provisioned.


set -e


echo "Creating a test admin user on the vagrant xnat VM"
useradd -m -s /bin/bash -U xnatadmin || echo "User already exists"
echo -e "${XNAT_ADMIN_PASSWORD}\n${XNAT_ADMIN_PASSWORD}" | passwd "$XNAT_ADMIN"
usermod -aG wheel "$XNAT_ADMIN"


echo "Copying the public SSH key for the admin user to allow ssh key login"
mkdir -p /home/"$XNAT_ADMIN"/.ssh/
chmod 700 /home/"$XNAT_ADMIN"/.ssh/
cp /vagrant/local/id_rsa.pub /home/"$XNAT_ADMIN"/.ssh/authorized_keys
chmod 644 /home/"$XNAT_ADMIN"/.ssh/authorized_keys
chown -R "$XNAT_ADMIN":"$XNAT_ADMIN" /home/"$XNAT_ADMIN"/.ssh/

echo "Creating the self-signed website certificates for the test xnat web server"
. "/vagrant/guest_scripts/create_vagrant_test_ssl_cert.sh"

echo "Installing modules"
yum install -y sendmail nano

echo "Disabling SELinux"
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
