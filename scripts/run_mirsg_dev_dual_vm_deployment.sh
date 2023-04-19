#!/usr/bin/env bash

# Run ansible playbook to deploy VMs on mirsg-dev.cs.ucl.ac.uk
#
# Usage: run_mirsg_dev_dual_vm_deployment.sh ssh_user
#
#   ssh_user:    is the username of your ssh account on the servers

set -e

SSH_USER=$1

ROOT_DIR="$(dirname "${BASH_SOURCE[0]}")"

# This points to the folder containing the playbooks.
# You may need to modify this depending on where this script is located.
PLAYBOOK_DIR="${ROOT_DIR}/../playbooks"

VAULT_PASSWORD_FILE="${VAULT_PASSWORD_FILE:-~/.ucl_xnat_vault_password}"

ANSIBLE_HOST_KEY_CHECKING="false" ansible-playbook \
--extra-vars "ssh_user=${SSH_USER} s3_bucket=${MIRSG_AWS_S3_BUCKET} s3_key=${MIRSG_AWS_S3_BUCKET_KEY}" \
--private-key "${ROOT_DIR}/../terraform/dual-vm-deployment/tf-cloud-init" \
"${PLAYBOOK_DIR}/mirsg_dev_dual_vm_deployment.yml" --vault-id "${VAULT_PASSWORD_FILE}"
