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
