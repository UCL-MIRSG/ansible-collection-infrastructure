locals {
  os_image = {
    name         = var.OS_IMAGE_DISPLAY_NAME
    namespace    = "default"
    display_name = var.OS_IMAGE_DISPLAY_NAME
    description  = ""
    source_type  = "download"
    url          = var.OS_IMAGE_URL
    tags         = { "format" = var.OS_IMAGE_FORMAT }
  }

  db_vm_data = {
    cpus        = 1
    description = "value"
    disks = [
      {
        name       = "rootdisk"
        size       = "10Gi"
        boot_order = 1
      },
      {
        name       = "emptydisk"
        size       = "40Gi"
        boot_order = 2
      }
    ]
    hostname        = var.DB_VM_NAME
    memory          = "8Gi"
    name            = var.DB_VM_NAME
    namespace       = "default"
    pg_port         = 5432
    pg_target_port  = 5432
    ssh_port        = 22
    ssh_target_port = 22
    tags = {
      "vm" = "db"
    }
  }

  web_vm_data = {
    cpus        = 1
    description = "value"
    disks = [
      {
        name       = "rootdisk"
        size       = "10Gi"
        boot_order = 1
      },
      {
        name       = "emptydisk"
        size       = "40Gi"
        boot_order = 2
      }
    ]
    hostname  = var.WEB_VM_NAME
    memory    = "8Gi"
    name      = var.WEB_VM_NAME
    namespace = "default"
    tags = {
      "vm" = "web"
    }
    http_port         = 80
    http_target_port  = 80
    https_port        = 443
    https_target_port = 443
    ssh_port          = 22
    ssh_target_port   = 22
  }

}

# create database VM
module "db_virtual_machine" {
  source = "github.com/UCL-MIRSG/mirsg-harvester-terraform-modules//modules/virtual-machine?ref=v1.0.5"

  user_data = templatefile("${path.module}/templates/user_data.yml.tftpl", {
    USER_NAME : var.USER_NAME,
    USER_PASSWORD_HASH : var.USER_PASSWORD_HASH
    USER_PUBLIC_KEY : var.USER_PUBLIC_KEY
  })
  os_image = local.os_image
  vm_data  = local.db_vm_data
}

# create web VM
module "web_virtual_machine" {
  source = "github.com/UCL-MIRSG/mirsg-harvester-terraform-modules//modules/virtual-machine?ref=v1.0.5"

  user_data = templatefile("${path.module}/templates/user_data.yml.tftpl", {
    USER_NAME : var.USER_NAME,
    USER_PASSWORD_HASH : var.USER_PASSWORD_HASH
    USER_PUBLIC_KEY : var.USER_PUBLIC_KEY
  })
  os_image = local.os_image
  vm_data  = local.web_vm_data
}

# create ssh NodePort for db VM
module "db_ssh_node_port" {
  source = "github.com/UCL-MIRSG/mirsg-harvester-terraform-modules//modules/kubernetes-nodeport?ref=v1.0.5"

  vm_name      = local.db_vm_data.name
  service_name = "${local.db_vm_data.name}-ssh"
  ports = {
    "${local.db_vm_data.name}-ssh-port" = {
      port        = local.db_vm_data.ssh_port
      target_port = local.db_vm_data.ssh_target_port
    }
  }
}

# create ssh NodePort for web VM
module "web_ssh_node_port" {
  source = "github.com/UCL-MIRSG/mirsg-harvester-terraform-modules//modules/kubernetes-nodeport?ref=v1.0.5"

  vm_name      = local.web_vm_data.name
  service_name = "${local.web_vm_data.name}-ssh"
  ports = {
    "${local.web_vm_data.name}-ssh-port" = {
      port        = local.web_vm_data.ssh_port
      target_port = local.web_vm_data.ssh_target_port
    }
  }
}

# create http and https NodePort for web VM
module "web_http_https_node_port" {
  source = "github.com/UCL-MIRSG/mirsg-harvester-terraform-modules//modules/kubernetes-nodeport?ref=v1.0.5"

  vm_name      = local.web_vm_data.name
  service_name = local.web_vm_data.name
  ports = {
    "${local.web_vm_data.name}-http-port" = {
      port        = local.web_vm_data.http_port,
      target_port = local.web_vm_data.http_target_port,
    },
    "${local.web_vm_data.name}-https-port" = {
      port        = local.web_vm_data.https_port,
      target_port = local.web_vm_data.https_target_port,
    }
  }
}

# create PG (5432) ClusterIP for db VM
module "db_pg_clusterip" {
  source = "github.com/UCL-MIRSG/mirsg-harvester-terraform-modules//modules/kubernetes-clusterip?ref=v1.0.5"

  vm_name        = local.db_vm_data.name
  service_name   = "${local.db_vm_data.name}-pg"
  clusterip_name = "${local.db_vm_data.name}-pg-port"
  port           = local.db_vm_data.pg_port
  target_port    = local.db_vm_data.pg_target_port
}

resource "local_file" "mirsg_dev_hosts" {
  content = templatefile("${path.module}/templates/mirsg_dev_hosts.yml.tftpl",
    {
      https_node_port : one([for port in module.web_http_https_node_port.node_port : port.node_port if can(regex("https", port.name))])
      db_ssh_cluster_ip : module.db_ssh_node_port.cluster_ip
      db_ssh_node_port : module.db_ssh_node_port.node_port[0].node_port
      web_ssh_cluster_ip : module.web_ssh_node_port.cluster_ip
      web_ssh_node_port : module.web_ssh_node_port.node_port[0].node_port
    }
  )
  filename = "${path.module}/../../ansible/inventories/development/mirsg_dev_hosts.yml"
}

resource "null_resource" "remote_exec" {
  depends_on = [
    module.web_virtual_machine
  ]
  provisioner "remote-exec" {
    inline = ["sudo yum upgrade -y", "echo Done!"]

    connection {
      host        = "mirsg-dev.cs.ucl.ac.uk"
      type        = "ssh"
      port        = module.web_ssh_node_port.node_port[0].node_port
      user        = var.USER_NAME
      private_key = file("${path.module}/${var.USER_PRIVATE_KEY_FILE}")
    }
  }

  provisioner "local-exec" {
    command = join(" ", [
      "ANSIBLE_HOST_KEY_CHECKING=False",
      "ansible-playbook -u ${var.USER_NAME}",
      "-i '${path.module}/../../ansible/inventories/development/mirsg_dev_hosts.yml'",
      "--private-key ${path.module}/${var.USER_PRIVATE_KEY_FILE}",
      "${path.module}/../../ansible/inventories/development/copy_mirsg_dev_cert.yml",
    "--vault-id ${path.module}/../../ansible/inventories/development/${var.VAULT_PASSWORD_FILE}"])
  }
}
