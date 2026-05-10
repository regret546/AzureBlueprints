
resource "azurerm_resource_group" "example" {
  name     = "rg-${var.application_name}"
  location = var.primary_location
}