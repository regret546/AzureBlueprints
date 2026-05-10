
resource "azurerm_resource_group" "hub" {
  name     = "rg-${var.application_name}-hub-${var.environment_name}"
  location = var.primary_location
}

resource "azurerm_resource_group" "spoke" {
  name     = "rg-${var.application_name}-spoke-${var.environment_name}"
  location = var.primary_location
}

/*
# Bastion Hub
module "hub" {
  source              = "./modules/hub"
  application_name    = var.application_name
  location            = var.primary_location
  resource_group_name = azurerm_resource_group.hub.name
}
*/

#Bastion Spoke
data "azurerm_virtual_network" "spokes" {
  for_each = {
    for vnet in var.spokes : vnet => vnet
  }
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}
