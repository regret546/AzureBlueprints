
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


#NIC NSG module
module "nic_nsg" {
  source = "./modules/nic-nsg"

  bastion_subnet_cidr = module.bastion.bastion_subnet_prefix

  allowed_ports = ["22", "3389"]

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }

  vm_nics = var.vm_nics
}
