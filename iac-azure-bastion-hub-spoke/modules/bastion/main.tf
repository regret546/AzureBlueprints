# Create hub virtual network (central network for shared services and connectivity)
resource "azurerm_virtual_network" "hub_vnet" {
  name                = "${var.application_name}-hub-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.hub_vnet_address_space

}

# Create dedicated subnet for Azure Bastion (must be named AzureBastionSubnet)
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = var.bastion_subnet_prefix
}

# Create public IP for Azure Bastion (used for secure inbound connectivity)
resource "azurerm_public_ip" "bastion_pip" {
  name                = "${var.application_name}-bastion-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

/*
# Deploy Azure Bastion host (enables secure RDP/SSH access to VMs via Azure portal)
resource "azurerm_bastion_host" "bastion" {
  name                = "${var.application_name}-hub"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
}
*/

