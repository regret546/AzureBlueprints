variable "application_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "hub_vnet_address_space" {
  description = "Address space for the Hub VNet"
  type        = list(string)
}

variable "bastion_subnet_prefix" {
  description = "CIDR for Azure Bastion subnet (must be /27 or larger)"
  type        = list(string)
}
