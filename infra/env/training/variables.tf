variable "name" {
  description = "A short name, e.g. 'aks-prod' (used in resource names)."
  type        = string
}

variable "location" {
  description = "Azure region, e.g. westeurope."
  type        = string
}

variable "resource_group_name" {
  description = "Existing RG where networking will be created."
  type        = string
}

variable "vnet_cidr" {
  description = "CIDR for the VNet."
  type        = string

}

variable "aks_subnet_cidr" {
  description = "CIDR for the AKS node subnet (private)."
  type        = string
}

variable "create_nat_gateway" {
  description = "Create NAT Gateway + static public IP and attach to AKS subnet."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "node_count" {
  description = "The number of nodes in the default node pool."
  type        = number
}

variable "vm_size" {
  description = "The size of the VMs in the default node pool."
  type        = string
}

variable "node_resource_group" {
  description = "The name of the resource group to create and manage the cluster's resources."
  type        = string
}

variable "k8s_version" {
  description = "The Kubernetes version to use for the AKS cluster."
  type        = string
}

variable "admin_username" {
  description = "Admin username for the Jumpbox VM."
  type        = string
  default     = "adminuser"
}

variable "jumpbox_ssh_public_key" {
  description = "SSH public key for the Jumpbox VM."
  type        = string
}

#variable "node_nsg_name" {
#  description = "node nsg name"
#  type        = string

#}