# Retrieve existing spoke VNets from input variable
data "azurerm_virtual_network" "spokes" {
  for_each = {
    for vnet in var.spokes : vnet.name => vnet
  }
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}
