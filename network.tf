resource "azurerm_virtual_network" "myazvnet" {
  name                = var.myvnet
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.kubertera.location
  resource_group_name = azurerm_resource_group.kubertera.name
}

resource "azurerm_subnet" "public_subnet1" {
  name = "Public_Subnet1"
  resource_group_name = azurerm_resource_group.kubertera.name
  virtual_network_name = azurerm_virtual_network.myazvnet.name
  address_prefixes = ["10.0.1.0/24"]
  
}

resource "azurerm_subnet" "private_subnet1" {
  name = "Private_Subnet1"
  resource_group_name = azurerm_resource_group.kubertera.name
  virtual_network_name = azurerm_virtual_network.myazvnet.name
  address_prefixes = ["10.0.2.0/24"]
  
}

resource "azurerm_network_interface" "nic1" {
  name = "vm1-nic"
  resource_group_name = azurerm_resource_group.kubertera.name
  location = azurerm_resource_group.kubertera.location
  ip_configuration {
    name = "nicipassignment"
    subnet_id = azurerm_subnet.private_subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "nsg1" {
  name = "nsg1azdevopskuber"
  resource_group_name = azurerm_resource_group.kubertera.name
  location = azurerm_resource_group.kubertera.location
    security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  } 
}

resource "azurerm_network_interface_security_group_association" "nsg1conwithnic1" {
  network_security_group_id = azurerm_network_security_group.nsg1.id
  network_interface_id = azurerm_network_interface.nic1.id
}