
# Create resource group for hub
resource "azurerm_resource_group" "hub" {
  name     = "rg-${var.application_name}-hub-${var.environment_name}"
  location = var.primary_location

  tags = {
    Country     = "PH"
    Application = "Bastion"
    Environment = "dev"
    Description = "Bastion Deployment through TF"
  }
}

# Hub module
module "bastion" {
  source              = "./modules/bastion"
  application_name    = var.application_name
  location            = var.primary_location
  resource_group_name = azurerm_resource_group.hub.name

  hub_vnet_address_space = ["10.200.0.0/20"]
  bastion_subnet_prefix  = ["10.200.1.0/27"]
}

#Vnet-peering moduke
module "vnet-peering" {
  for_each = var.spokes
  source   = "./modules/vnet-peering"

  #Hub
  hub_resource_group_name       = azurerm_resource_group.hub.name
  hub_virtual_network_name      = module.bastion.vnet_name
  hub_remote_virtual_network_id = module.bastion.vnet_id

  #Spoke
  spoke_name                      = each.value.name
  spoke_resource_group_name       = each.value.resource_group_name
  spoke_virtual_network_name      = each.value.name
  spoke_remote_virtual_network_id = data.azurerm_virtual_network.spokes[each.key].id
}


# Create NSG per subnet
resource "azurerm_network_security_group" "spoke_nsg" {
  for_each = {
    for s in local.spoke_subnets :
    "${s.vnet_name}-${s.subnet_name}" => s
  }

  name                = "nsg-${var.application_name}-access"
  location            = data.azurerm_virtual_network.spokes[each.value.spoke_key].location
  resource_group_name = each.value.resource_group

  security_rule {
    name                       = "Allow-Bastion-RDP-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "3389"]
    source_address_prefix      = module.bastion.bastion_subnet_prefix[0]
    destination_address_prefix = "*"
  }
}

# Attach NSG to subnet
resource "azurerm_subnet_network_security_group_association" "spoke_assoc" {
  for_each = {
    for s in local.spoke_subnets :
    "${s.vnet_name}-${s.subnet_name}" => s
  }

  subnet_id                 = data.azurerm_subnet.spokes[each.key].id
  network_security_group_id = azurerm_network_security_group.spoke_nsg[each.key].id
}
