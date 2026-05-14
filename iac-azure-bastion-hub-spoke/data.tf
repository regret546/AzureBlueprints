# Get existing spoke VNets
data "azurerm_virtual_network" "spokes" {
  for_each = var.spokes

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}

# Get existing subnets
data "azurerm_subnet" "spokes" {
  for_each = {
    for s in local.spoke_subnets :
    "${s.vnet_name}-${s.subnet_name}" => s
  }

  name                 = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.resource_group
}
