# ELB 설정
# public ip
# Web nif
# Front ip 설정
# backend , association
# probe 80, health
# inbound rule 80
# outbound rule

# ELB Public ip
resource "azurerm_public_ip" "elb_pub" {
  name                = "elb_pub"
  location            = azurerm_resource_group.jwh_rg.location
  resource_group_name = azurerm_resource_group.jwh_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  availability_zone   = 1
}

# Web 가상머신 서브넷 인터페이스 생성
resource "azurerm_network_interface" "jwh_web_vm_nif" {
  name                = "jwh_web_vm_nif"
  location            = azurerm_resource_group.jwh_rg.location
  resource_group_name = azurerm_resource_group.jwh_rg.name

  ip_configuration {
    name                          = "web_vm_pub"
    subnet_id                     = azurerm_subnet.WEB_sub.id
    private_ip_address_allocation = "Dynamic"
  }
}

# ELB
# ELB Front ip 설정
resource "azurerm_lb" "jwh_lb" {
  name                = "jwh_lb"
  location            = azurerm_resource_group.jwh_rg.location
  resource_group_name = azurerm_resource_group.jwh_rg.name
  sku                 = "Standard"

  # ELB FrontEnd Ip
  frontend_ip_configuration {
    name                 = "lb_front_pub"
    public_ip_address_id = azurerm_public_ip.elb_pub.id
  }
}

# ELB backend
resource "azurerm_lb_backend_address_pool" "jwh_elb_back" {
  loadbalancer_id = azurerm_lb.jwh_lb.id
  name            = "jwh_elb_back"

  depends_on = [
    azurerm_lb.jwh_lb
  ]
}

# ELB backend association
resource "azurerm_network_interface_backend_address_pool_association" "jwh_elb_back_nif_ass" {
  network_interface_id    = azurerm_network_interface.jwh_web_vm_nif.id
  ip_configuration_name   = "web_vm_pub"
  backend_address_pool_id = azurerm_lb_backend_address_pool.jwh_elb_back.id

  depends_on = [
    azurerm_lb_backend_address_pool.jwh_elb_back
  ]
}

##### ELB nat_rule & Backend 추가 ######
resource "azurerm_network_interface_nat_rule_association" "jwh_elb_back_nat_ass" {
  network_interface_id    = azurerm_network_interface.jwh_web_vm_nif.id
  ip_configuration_name   = "web_vm_pub"
  nat_rule_id = azurerm_lb_nat_rule.jwh_ssh_rule.id
}

# ELB probe
resource "azurerm_lb_probe" "jwh_elb_probe" {
  resource_group_name = azurerm_resource_group.jwh_rg.name
  loadbalancer_id     = azurerm_lb.jwh_lb.id
  name                = "jwh_elb_probe"
  protocol            = "Http"
  request_path        = "/health.html"
  port                = 80

  depends_on = [
    azurerm_network_interface_backend_address_pool_association.jwh_elb_back_nif_ass
  ]
}

# ELB inbound http rule
resource "azurerm_lb_rule" "jwh_http_rule" {
  name                           = "jwh_http_rule"
  resource_group_name            = azurerm_resource_group.jwh_rg.name
  loadbalancer_id                = azurerm_lb.jwh_lb.id
  probe_id                       = azurerm_lb_probe.jwh_elb_probe.id
  disable_outbound_snat          = true
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.jwh_elb_back.id]
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "lb_front_pub"
  protocol                       = "Tcp"

  depends_on = [
    azurerm_lb_probe.jwh_elb_probe
  ]
}

##### ELB nat_rule ssh 포트 추가 #####
resource "azurerm_lb_nat_rule" "jwh_ssh_rule" {
  resource_group_name = azurerm_resource_group.jwh_rg.name
  loadbalancer_id = azurerm_lb.jwh_lb.id
  name = "jwh_ssh_rule"
  protocol = "Tcp"
  frontend_port = 22
  backend_port = 22
  frontend_ip_configuration_name = "lb_front_pub"
}

# ELB outbound rule
resource "azurerm_lb_outbound_rule" "jwh_lb_out" {
  resource_group_name      = azurerm_resource_group.jwh_rg.name
  loadbalancer_id          = azurerm_lb.jwh_lb.id
  name                     = "jwh_lb_out"
  protocol                 = "All"
  backend_address_pool_id  = azurerm_lb_backend_address_pool.jwh_elb_back.id
  allocated_outbound_ports = 1024

  frontend_ip_configuration {
    name = "lb_front_pub"
  }

  depends_on = [
    azurerm_lb_rule.jwh_http_rule
  ]
}


