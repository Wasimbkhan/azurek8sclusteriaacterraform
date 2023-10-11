# VM 1 creation in zone 1
resource "azurerm_virtual_machine" "webserver1" {
  depends_on = [ azurerm_network_interface.nic1 ]
  name                  = "webserver1"
  location              = azurerm_resource_group.kubertera.location
  resource_group_name   = azurerm_resource_group.kubertera.name
  network_interface_ids = [azurerm_network_interface.nic1.id]
  vm_size               = "Standard_B1s"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  storage_os_disk {
      name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "Webserver1"
    admin_username = "Ubuntu"
    admin_password = "Password1234!"

    custom_data = (
    <<-EOF
        #!/bin/bash
        echo "Hello from webserver 1" > /tmp/user_data.txt
    EOF
    )
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

  zones = ["1"]

  tags = {
    environment = "Dev"
  }

}

# VM 2 creation in zone 2
resource "azurerm_virtual_machine" "webserver2" {
  depends_on = [ azurerm_network_interface.nic2 ]
  name                  = "webserver2"
  location              = azurerm_resource_group.kubertera.location
  resource_group_name   = azurerm_resource_group.kubertera.name
  network_interface_ids = [azurerm_network_interface.nic2.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  storage_os_disk {
      name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "Webserver1"
    admin_username = "Ubuntu"
    admin_password = "Password1234!"

    custom_data = (
    <<-EOF
        #!/bin/bash
        echo "Hello from Webserver 2" > /tmp/user_data.txt
    EOF
    )
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

  zones = ["2"]

  tags = {
    environment = "Dev"
  }

}