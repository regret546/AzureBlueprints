variable "bastion_subnet_cidr" {
  description = "CIDR range of the Azure Bastion subnet allowed to connect to the VM NICs."
  type        = string
}

variable "vm_nics" {
  description = "Map of VM NIC configurations for optional NIC-level NSG management. Leave empty to disable."
  type = map(object({
    nic_id              = string # Resource ID of the target VM network interface.
    resource_group_name = string # Resource group where the NSG will be created or managed.
    location            = string # Azure region where the NSG will be created.
    create_nsg          = bool   # True = create new NSG and attach to NIC. False = use existing NSG.
    existing_nsg_id     = string # Existing NSG resource ID when create_nsg is false. Use null when create_nsg is true.
  }))
  default = {}
}

variable "allowed_ports" {
  description = "Ports allowed from Azure Bastion to the VM NICs."
  type        = list(string)
  default     = ["22", "3389"]
}

variable "tags" {
  description = "Tags to apply to newly created NSGs."
  type        = map(string)
  default     = {}
}
