# To be used by Ansible in-memory inventory
output "terraform_var_host_list" {
  value = [
    {
      "terraform_var_ip" : local.web_ssh_cluster_ip,
      "terraform_var_port" : local.web_ssh_node_port,
    }
  ]
}
