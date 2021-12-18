#---------------------------------------------------#
# ILB
resource "azurerm_lb" "jwh_ilb" {
  name                = "jwh_ilb"
  location            = azurerm_resource_group.jwh_rg.location
  resource_group_name = azurerm_resource_group.jwh_rg.name
  sku                 = "Standard"
  
  frontend_ip_configuration {
    name                          = "ilb_front_ip"
    subnet_id                     = azurerm_subnet.WAS_sub.id
    private_ip_address_allocation = "Dynamic"
  }
}

# ilb back
resource "azurerm_lb_backend_address_pool" "jwh_ilb_back" {
  loadbalancer_id = azurerm_lb.jwh_ilb.id
  name            = "jwh_ilb_back"
}

# # ilb와 was 연결
# resource "azurerm_network_interface_backend_address_pool_association" "jwh_ilb_back_nif_ass" {
#   network_interface_id    = azurerm_network_interface.jwh_was_vm_nif.id
#   ip_configuration_name   = "was_vm_pub"
#   backend_address_pool_id = azurerm_lb_backend_address_pool.jwh_ilb_back.id

#   depends_on = [
#     azurerm_virtual_machine.jwh_was_vm
#   ]
# }

# ilb probe
resource "azurerm_lb_probe" "jwh_ilb_probe" {
  resource_group_name = azurerm_resource_group.jwh_rg.name
  loadbalancer_id     = azurerm_lb.jwh_ilb.id
  name                = "jwh_ilb_probe"
  port                = 8080
}

# ilb inbound
resource "azurerm_lb_rule" "jwh_ilb_rule" {
  name                           = "jwh_ilb_rule"
  resource_group_name            = azurerm_resource_group.jwh_rg.name
  loadbalancer_id                = azurerm_lb.jwh_ilb.id
  probe_id                       = azurerm_lb_probe.jwh_ilb_probe.id
  disable_outbound_snat          = true
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.jwh_ilb_back.id]
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = "ilb_front_ip"
  protocol                       = "Tcp"
}

