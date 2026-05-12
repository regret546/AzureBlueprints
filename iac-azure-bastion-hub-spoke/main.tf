# Create resource group for hub (centralized networking components)
resource "azurerm_resource_group" "hub" {
  name     = "rg-${var.application_name}-hub-${var.environment_name}"
  location = var.primary_location
}

# Deploy hub module (includes hub VNet and Azure Bastion)
module "hub" {
  source              = "./modules/hub"
  application_name    = var.application_name
  location            = var.primary_location
  resource_group_name = azurerm_resource_group.hub.name

  hub_vnet_address_space = ["10.200.0.0/20"]
  bastion_subnet_prefix  = ["10.200.1.0/27"]
}


# Retrieve existing spoke VNets from input variable
data "azurerm_virtual_network" "spokes" {
  for_each = {
    for vnet in var.spokes : vnet.name => vnet
  }
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}

# Create peering from hub VNet to each spoke VNet
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  for_each = data.azurerm_virtual_network.spokes

  name                      = "hub-to-${each.key}"
  resource_group_name       = azurerm_resource_group.hub.name
  virtual_network_name      = module.hub.vnet_name
  remote_virtual_network_id = each.value.id
}

# Create peering from each spoke VNet back to the hub VNet
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  for_each = data.azurerm_virtual_network.spokes

  name                      = "${each.key}-to-hub"
  resource_group_name       = each.value.resource_group_name
  virtual_network_name      = each.value.name
  remote_virtual_network_id = module.hub.vnet_id
}
