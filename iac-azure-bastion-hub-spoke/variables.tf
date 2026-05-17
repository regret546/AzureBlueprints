variable "application_name" {
  type = string
}
variable "environment_name" {
  type = string
}
variable "primary_location" {
  type = string
}

variable "spokes" {
  description = "List of existing VNets to peer with hub"
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    subnets = map(object({
      name = string
    }))
  }))
}

variable "vm_nics" {
  description = "Map of VM NIC configurations for optional NIC-level NSG management."
  type = map(object({
    nic_id              = string # Resource ID of the target VM NIC
    resource_group_name = string # Resource group where the NSG and rules will be created
    location            = string # Azure region where the NSG will be created
    create_nsg          = bool   # True = create new NSG, false = use existing NSG
    existing_nsg_id     = string # Existing NSG resource ID when create_nsg is false, otherwise null
  }))
  default = {}
}
