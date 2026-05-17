

#Hub variables
variable "hub_resource_group_name" {
  type = string
}

variable "hub_virtual_network_name" {
  type = string
}

variable "hub_remote_virtual_network_id" {
  type = string
}


#Spoke variables
variable "spoke_name" {
  type = string
}

variable "spoke_resource_group_name" {
  type = string
}

variable "spoke_virtual_network_name" {
  type = string
}

variable "spoke_remote_virtual_network_id" {
  type = string
}


