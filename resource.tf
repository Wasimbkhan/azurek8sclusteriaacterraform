resource "azurerm_resource_group" "kubertera" {
  name     = "${var.rg_name}_${var.environment}"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "kubertera" {
  name = var.aziaack8scluster_name
  location = azurerm_resource_group.kubertera.location
  resource_group_name = azurerm_resource_group.kubertera.name
  dns_prefix = var.dns_prefix

  default_node_pool {
    name       = "default"
    node_count = var.nodecount
    vm_size    = "Standard_D2_v2"
  }

  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  service_principal {
    client_id = var.client_id
    client_secret = var.client_secret
  }

   tags = {
    Environment = var.environment
  }
}

