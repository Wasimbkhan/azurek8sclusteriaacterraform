### Create Virtual network ###
resource "azurerm_virtual_network" "myazvnet" {
  name                = var.myvnet
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.kubertera.location
  resource_group_name = azurerm_resource_group.kubertera.name
}

### Create one public subnet ###
resource "azurerm_subnet" "public_subnet1" {
  name = "Public_Subnet1"
  resource_group_name = azurerm_resource_group.kubertera.name
  virtual_network_name = azurerm_virtual_network.myazvnet.name
  address_prefixes = ["10.0.1.0/24"]
  
}

### Create one private subnet ###
resource "azurerm_subnet" "private_subnet1" {
  name = "Private_Subnet1"
  resource_group_name = azurerm_resource_group.kubertera.name
  virtual_network_name = azurerm_virtual_network.myazvnet.name
  address_prefixes = ["10.0.2.0/24"]
  
}

### Create one NIC for Webserver 1 ###
resource "azurerm_network_interface" "nic1" {
  depends_on = [ azurerm_public_ip.PIPNIC1 ]
  name = "vm1-nic"
  resource_group_name = azurerm_resource_group.kubertera.name
  location = azurerm_resource_group.kubertera.location
  ip_configuration {
    name = "vm1nicip"
    subnet_id = azurerm_subnet.private_subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

### Create 2nd NIC Card for Webserver 2 ###
  resource "azurerm_network_interface" "nic2" {
    depends_on = [ azurerm_public_ip.PIPNIC2 ]
    name = "vm2-nic"
    resource_group_name = azurerm_resource_group.kubertera.name
    location = azurerm_resource_group.kubertera.location
    ip_configuration {
      name = "vm2nicip"
      subnet_id = azurerm_subnet.public_subnet1.id
      private_ip_address_allocation = "Dynamic"
    }
  }

### Create Network Security group ###
resource "azurerm_network_security_group" "nsg1" {
  name = "nsg1azdevopskuber"
  resource_group_name = azurerm_resource_group.kubertera.name
  location = azurerm_resource_group.kubertera.location
    security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  } 
   security_rule {
    name                       = "HTTP"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  } 
     security_rule {
    name                       = "RDP"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  } 
}

### Associate NIC1 & NIC2 with NSG ###
resource "azurerm_network_interface_security_group_association" "nsg1conwithnic1" {
  network_security_group_id = azurerm_network_security_group.nsg1.id
  network_interface_id = azurerm_network_interface.nic1.id
}

resource "azurerm_network_interface_security_group_association" "nsg1conwithnic2" {
  network_security_group_id = azurerm_network_security_group.nsg1.id
  network_interface_id = azurerm_network_interface.nic2.id
}

### Create Public ip for lb1  ###
resource "azurerm_public_ip" "lbPIP" {
  name = "PublicIPforLB"
  resource_group_name = azurerm_resource_group.kubertera.name
  location = azurerm_resource_group.kubertera.location
  allocation_method = "Static"
  sku = "Standard"
}

### Create Load balancer & assign Public IP ###
resource "azurerm_lb" "myloadbalancer" {
  name = "myloadbalcner"
  resource_group_name = azurerm_resource_group.kubertera.name
  location = azurerm_resource_group.kubertera.location
  sku = "Standard"

  frontend_ip_configuration {
    name = "LBPublicIP"
    public_ip_address_id = azurerm_public_ip.lbPIP.id
  }
}

### Create NAT Rule for LB to route traffic ###
resource "azurerm_lb_nat_rule" "natruleforRDP" {
  name = "RDP Access"
  resource_group_name = azurerm_resource_group.kubertera.name
  loadbalancer_id = azurerm_lb.myloadbalancer.id
  protocol = "TCP"
  frontend_port = 3389
  backend_port = 3389
  frontend_ip_configuration_name = "LBPublicIP"
  
}

resource "azurerm_lb_nat_rule" "natruleforHttp" {
  name = "Http"
  resource_group_name = azurerm_resource_group.kubertera.name
  loadbalancer_id = azurerm_lb.myloadbalancer.id
  protocol = "TCP"
  frontend_port = 8080
  backend_port = 8080
  frontend_ip_configuration_name = "LBPublicIP"
  
}

resource "azurerm_lb_nat_rule" "natruleforSSH" {
  name = "SSH"
  resource_group_name = azurerm_resource_group.kubertera.name
  loadbalancer_id = azurerm_lb.myloadbalancer.id
  protocol = "TCP"
  frontend_port = 22
  backend_port = 22
  frontend_ip_configuration_name = "LBPublicIP"
  
}

### Create LB backend pool ###

resource "azurerm_lb_backend_address_pool" "lbbackendpool" {
  name = "LBBackendPool"
  loadbalancer_id = azurerm_lb.myloadbalancer.id
  
}

### associate webservers to backend pool ###

resource "azurerm_network_interface_backend_address_pool_association" "backendpoolassociation" {
  network_interface_id = azurerm_network_interface.nic1.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.lbbackendpool.id
  ip_configuration_name = "vm1nicip"
}

resource "azurerm_network_interface_backend_address_pool_association" "backendpoolassociation1" {
  network_interface_id = azurerm_network_interface.nic2.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.lbbackendpool.id
  ip_configuration_name = "vm2nicip"
}


