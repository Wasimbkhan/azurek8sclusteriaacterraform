### Create Virtual network ###
resource "azurerm_virtual_network" "myazvnet" {
  name                = var.myvnet
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.kubertera.location
  resource_group_name = azurerm_resource_group.kubertera.name
}

### Create one public subnet ###
resource "azurerm_subnet" "Private_subnet1" {
  name = "Private_Subnet1"
  resource_group_name = azurerm_resource_group.kubertera.name
  virtual_network_name = azurerm_virtual_network.myazvnet.name
  address_prefixes = ["10.1.1.0/24"]
  
}

### Create one private subnet ###
resource "azurerm_subnet" "Private_subnet2" {
  name = "Private_Subnet2"
  resource_group_name = azurerm_resource_group.kubertera.name
  virtual_network_name = azurerm_virtual_network.myazvnet.name
  address_prefixes = ["10.1.2.0/24"]
  
}

resource "azurerm_subnet" "AKS_subnet" {
  name = "AKS_Subnet"
  resource_group_name = azurerm_resource_group.kubertera.name
  virtual_network_name = azurerm_virtual_network.myazvnet.name
  address_prefixes = ["10.1.3.0/24"]
  
}


### Create one NIC for Webserver 1 ###
resource "azurerm_network_interface" "nic1" {
  name = "vm1-nic"
  resource_group_name = azurerm_resource_group.kubertera.name
  location = azurerm_resource_group.kubertera.location
  ip_configuration {
    name = "vm1nicip"
    subnet_id = azurerm_subnet.Private_subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

### Create 2nd NIC Card for Webserver 2 ###
  resource "azurerm_network_interface" "nic2" {
    name = "vm2-nic"
    resource_group_name = azurerm_resource_group.kubertera.name
    location = azurerm_resource_group.kubertera.location
    ip_configuration {
      name = "vm2nicip"
      subnet_id = azurerm_subnet.Private_subnet2.id
      private_ip_address_allocation = "Dynamic"
    }
  }

### Create Network Security group inbound rule ###
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
    destination_port_range     = "80"
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
  depends_on = [ azurerm_public_ip.lbPIP ]
  name = "myloadbalancer"
  resource_group_name = azurerm_resource_group.kubertera.name
  location = azurerm_resource_group.kubertera.location
  sku = "basic"

  frontend_ip_configuration {
    name = "LBPublicIP"
    public_ip_address_id = azurerm_public_ip.lbPIP.id
  }
}

### Create NAT Rule for LB to route traffic ###
# resource "azurerm_lb_nat_rule" "natruleforRDP" {
#   name = "RDPAccess"
#   resource_group_name = azurerm_resource_group.kubertera.name
#   loadbalancer_id = azurerm_lb.myloadbalancer.id
#   protocol = "Tcp"
#   frontend_port_start = 3389
#   frontend_port_end = 3390
#   backend_port = 3389
#   frontend_ip_configuration_name = "LBPublicIP"
#   backend_address_pool_id = azurerm_lb_backend_address_pool.lbbackendpool.id
  
# }

# resource "azurerm_lb_nat_rule" "natruleforHttp" {
#   name = "HTTP"
#   resource_group_name = azurerm_resource_group.kubertera.name
#   loadbalancer_id = azurerm_lb.myloadbalancer.id
#   protocol = "Tcp"
#   frontend_port_start = 8080
#   frontend_port_end = 8081
#   backend_port = 8080
#   frontend_ip_configuration_name = "LBPublicIP"
#   backend_address_pool_id = azurerm_lb_backend_address_pool.lbbackendpool.id
#   enable_floating_ip = false
# }

resource "azurerm_lb_nat_rule" "natruleforSSH" {
  name = "SSH"
  resource_group_name = azurerm_resource_group.kubertera.name
  loadbalancer_id = azurerm_lb.myloadbalancer.id
  protocol = "Tcp"
  frontend_port_start = 22
  frontend_port_end = 23
  backend_port = 22
  frontend_ip_configuration_name = "LBPublicIP"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lbbackendpool.id
  enable_floating_ip = false
}

### Create LB rule ###

resource "azurerm_lb_rule" "LBinboundrule" {
  name = "Http"
  loadbalancer_id = azurerm_lb.myloadbalancer.id
  protocol = "Tcp"
  frontend_port = 80
  backend_port = 80
  frontend_ip_configuration_name = "LBPublicIP"
  disable_outbound_snat = true
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.lbbackendpool.id]
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

resource "azurerm_lb_outbound_rule" "lboutboundrule" {
  name = "LBOutboundrule"
  loadbalancer_id = azurerm_lb.myloadbalancer.id
  protocol = "Tcp"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lbbackendpool.id
  frontend_ip_configuration {
    name = "LBPublicIP"
  }
}

### Create azure firewall ###

# resource "azurerm_firewall" "AKSfirewall" {
#   name                = "testfirewall"
#   location            = azurerm_resource_group.kubertera.location
#   resource_group_name = azurerm_resource_group.kubertera.name
#   sku_name            = "AZFW_VNet"
#   sku_tier            = "Standard"

#   ip_configuration {
#     name                 = "configuration"
#     subnet_id            = 
#     public_ip_address_id = 
#   }
# }
