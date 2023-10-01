resource "azurerm_resource_group" "devvm" {
  name     = "${var.rg_name}_${var.environment}"
  location = var.location
}

# resource "azurerm_kubernetes_cluster" "iaack8" {
#   name = var.aziaack8scluster_name
#   location = azurerm_resource_group.iaack8s.location
#   resource_group_name = azurerm_resource_group.iaack8s.name
#   dns_prefix = var.dns_prefix

#   default_node_pool {
#     name       = "default"
#     node_count = var.nodecount
#     vm_size    = "Standard_D2_v2"
#   }
#   linux_profile {

#     admin_username = "ubuntu"
#     ssh_key {
#       key_data = file(var.ssh_public_key)
#     }
#   }

#   service_principal {
#     client_id = var.client_id
#     client_secret = var.client_secret
#   }

#   tags {
#     environment = var.environment
#   }
# }

resource "azurerm_virtual_network" "devvm" {
  name                = "devvm-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.devvm.location
  resource_group_name = azurerm_resource_group.devvm.name
}