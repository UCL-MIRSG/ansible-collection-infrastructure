# Role Name

Creates SSL cert and key for monitoring clients.

## Role Variables

The following are variables required by this role:

- `monitoring_client.cert_dir`: The folder in which the SSL cert will be created
  on the client.
- `monitoring_client.owner`: The OS user that will have ownership of the cert.
- `monitoring_client.group`: The OS group to which the `owner` belongs. -
  `monitoring_client.ssl_key_file`: The full path to the SSL private key file.
- `monitoring_client.ssl_csr_file`: The full path to the SSL cert file.
- `monitoring_temp_files_cert_dir`: The temporary location on the Ansible
  controller where the cert and key will be stored.

## Example Playbook

    hosts: monitoring_service

    roles:
      - create_monitoring_client_csr

## License

[BSD 3-Clause
License](https://github.com/UCL-MIRSG/ansible-collection-infrastructure/blob/main/LICENSE).

## Author Information

This role was created by the [Medical Imaging Research Software
Group](https://www.ucl.ac.uk/advanced-research-computing/expertise/research-software-development/medical-imaging-research-software-group)
at [UCL](https://www.ucl.ac.uk/).
