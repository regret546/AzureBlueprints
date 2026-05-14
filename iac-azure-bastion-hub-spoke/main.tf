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

  # Dynamic Hub VNet CIDR (adjustable per environment)
  hub_vnet_address_space = ["10.200.0.0/20"]

  # Bastion subnet CIDR (can be provided or derived inside module)
  bastion_subnet_prefix = ["10.200.1.0/27"]
}

# Create peering from hub VNet to each spoke VNet
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  for_each = var.spokes

  name                      = "hub-to-${each.key}"
  resource_group_name       = azurerm_resource_group.hub.name
  virtual_network_name      = module.hub.vnet_name
  remote_virtual_network_id = data.azurerm_virtual_network.spokes[each.value.name].id
}

# Create peering from each spoke VNet back to the hub VNet
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  for_each = var.spokes

  name                      = "${each.key}-to-hub"
  resource_group_name       = each.value.resource_group_name
  virtual_network_name      = each.value.name
  remote_virtual_network_id = module.hub.vnet_id
}

# Add NSG 
resource "azurerm_network_security_group" "spoke_nsg" {
  for_each = var.spokes

  name                = "nsg-${each.key}"
  location            = data.azurerm_virtual_network.spokes[each.value.name].location
  resource_group_name = each.value.resource_group_name

  security_rule {
    name                       = "Allow-Bastion-RDP-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "3389"]
    source_address_prefix      = module.hub.bastion_subnet_prefix[0]
    destination_address_prefix = "*"
  }

}
