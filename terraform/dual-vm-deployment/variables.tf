variable "KUBECONFIG" {
  description = "kubeconfig filename"
  type        = string
}

variable "USER_NAME" {
  description = "OS user to create"
  type        = string
}

variable "USER_PASSWORD_HASH" {
  description = "OS user password hash"
  type        = string
}

variable "USER_PUBLIC_KEY" {
  description = "Public key for OS user"
  type        = string
}

variable "USER_PRIVATE_KEY_FILE" {
  description = "Path to private key for OS user"
  type        = string
}

variable "VAULT_PASSWORD_FILE" {
  description = "Path to Ansible vault file"
  type        = string
}

variable "OS_IMAGE_DISPLAY_NAME" {
  description = "Name of the OS being installed on the VMs as displayed in the Harvester UI."
  type        = string
}

variable "OS_IMAGE_URL" {
  description = "The URL from which the OS image will be downloaded."
  type        = string
}

variable "OS_IMAGE_FORMAT" {
  description = "The format of the image being deployed (e.g. qcow2)."
  type        = string
}

variable "DB_VM_NAME" {
  description = "Name of database VM being created"
  type        = string
}

variable "WEB_VM_NAME" {
  description = "Name of database VM being created"
  type        = string
}
