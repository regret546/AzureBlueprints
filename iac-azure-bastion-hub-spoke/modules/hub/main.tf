resource "azurerm_virtual_network" "hub_vnet" {
  name                = "${var.application_name}-hub-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.100.0.0/20"]
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = ["10.100.1.0/27"]
}

resource "azurerm_public_ip" "bastion_pip" {
  name                = "${var.application_name}-bastion-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name                = "${var.application_name}-bastion"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
}
