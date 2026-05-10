variable "application_name" {
  type = string
}
variable "environment_name" {
  type = string
}
variable "primary_location" {
  type = string
}

variable "spokes" {
  description = "List of existing VNets to peer with hub"
  type = list(object({
    name                = string
    resource_group_name = string
  }))
}
