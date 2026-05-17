locals {
  # NICs where Terraform should create a new NSG
  create_nsgs = {
    for k, v in var.vm_nics : k => v
    if v.create_nsg
  }

  # NICs that will use an existing NSG
  existing_nsgs = {
    for k, v in var.vm_nics : k => v
    if !v.create_nsg
  }

  # Final NSG IDs used across the module
  # Combines newly created NSGs and existing NSGs into one map
  effective_nsg_ids = merge(
    {
      for k, v in azurerm_network_security_group.this :
      k => v.id
    },
    {
      for k, v in local.existing_nsgs :
      k => v.existing_nsg_id
    }
  )
}
