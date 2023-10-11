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
  depends_on = [ azurerm_public_ip.publicip ]
  name = "vm1-nic"
  resource_group_name = azurerm_resource_group.kubertera.name
  location = azurerm_resource_group.kubertera.location
  ip_configuration {
    name = "vm1nicip"
    subnet_id = azurerm_subnet.private_subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.publicip.id
  }
}
  resource "azurerm_network_interface" "nic2" {
    depends_on = [ azurerm_public_ip.publicip ]
    name = "vm2-nic"
    resource_group_name = azurerm_resource_group.kubertera.name
    location = azurerm_resource_group.kubertera.location
    ip_configuration {
      name = "vm2nicip"
      subnet_id = azurerm_subnet.public_subnet1.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id = azurerm_public_ip.PIPNIC2.id
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

resource "azurerm_network_interface_security_group_association" "nsg1conwithnic2" {
  network_security_group_id = azurerm_network_security_group.nsg1.id
  network_interface_id = azurerm_network_interface.nic2.id
}


resource "azurerm_public_ip" "publicip" {
  name = "publicipaloocation"
  resource_group_name = azurerm_resource_group.kubertera.name
  location = azurerm_resource_group.kubertera.location
  allocation_method = "Static"
  
}

resource "azurerm_public_ip" "PIPNIC2" {
  name = "nic2publicip"
  resource_group_name = azurerm_resource_group.kubertera.name
  location = azurerm_resource_group.kubertera.location
  allocation_method = "Static"
  zones = ["2"]
}