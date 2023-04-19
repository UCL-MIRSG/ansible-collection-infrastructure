terraform {
  required_version = ">= 0.13"
  required_providers {
    ansible = {
      source  = "ansible/ansible"
      version = "1.0.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    harvester = {
      source  = "harvester/harvester"
      version = "0.6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.16.1"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
  }
}

provider "kubernetes" {
  config_path = "${path.module}/${var.KUBECONFIG}"
}

provider "harvester" {
  kubeconfig = "${path.module}/${var.KUBECONFIG}"
}

terraform {
  backend "s3" {
    encrypt        = true
    kms_key_id     = "alias/tf-rs-key-mirsg-dev"
    dynamodb_table = "tf-rs-lock-mirsg-dev"
  }
}
