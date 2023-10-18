### VM 1 creation in zone 1 ###

resource "azurerm_virtual_machine" "webserver1" {
  depends_on = [ azurerm_network_interface.nic1 ]
  name                  = "webserver1"
  location              = azurerm_resource_group.kubertera.location
  resource_group_name   = azurerm_resource_group.kubertera.name
  network_interface_ids = [azurerm_network_interface.nic1.id]
  vm_size               = "Standard_B1ls"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  storage_os_disk {
      name              = "webserver1osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "Webserver1"
    admin_username = "ubuntu"
    admin_password = "Password1234!"

    custom_data = (
    <<EOF
        #!/bin/bash
        apt update
        apt install -y nginx
    EOF
    )
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file(var.ssh_public_key)
      path = "/home/Ubuntu/.ssh/authorized_keys"
    }
  }

  zones = ["1"]

  tags = {
    environment = "Dev"
  }

}

#### VM 2 creation in zone 2 ###

resource "azurerm_virtual_machine" "webserver2" {
  depends_on = [ azurerm_network_interface.nic2 ]
  name                  = "webserver2"
  location              = azurerm_resource_group.kubertera.location
  resource_group_name   = azurerm_resource_group.kubertera.name
  network_interface_ids = [azurerm_network_interface.nic2.id]
  vm_size               = "Standard_B1ls"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  storage_os_disk {
      name              = "webserver2osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "Webserver2"
    admin_username = "Ubuntu"
    admin_password = "Password1234!"

     custom_data = (
    <<EOF
        #!/bin/bash
        apt update
        apt install -y nginx
    EOF
    )

  }
  os_profile_linux_config {
    disable_password_authentication = true
     ssh_keys {
      key_data = file(var.ssh_public_key)
      path = "/home/Ubuntu/.ssh/authorized_keys"
    }
  }

  zones = ["2"]

  tags = {
    environment = "Dev"
  }
   
}