# 가상네트워크 설정
# Vnet    192.168.0.0/16
# Web     192.168.1.0/24
# Was     192.168.2.0/24
# DB      192.168.3.0/24
# Bastion 192.168.4.0/24
# Was_img 192.168.5.0/24

# Vnet
resource "azurerm_virtual_network" "jwh_vnet" {
  name                = "jwh_vnet"
  location            = azurerm_resource_group.jwh_rg.location
  resource_group_name = azurerm_resource_group.jwh_rg.name
  address_space       = ["192.168.0.0/16"]
}

#WEB_서브넷
resource "azurerm_subnet" "WEB_sub" {
  name                 = "WEB_sub"
  resource_group_name  = azurerm_virtual_network.jwh_vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.jwh_vnet.name
  address_prefixes     = ["192.168.1.0/24"]
}

#WAS_서브넷
resource "azurerm_subnet" "WAS_sub" {
  name                 = "WAS_sub"
  resource_group_name  = azurerm_virtual_network.jwh_vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.jwh_vnet.name
  address_prefixes     = ["192.168.2.0/24"]
}

#DB_서브넷
resource "azurerm_subnet" "DB_sub" {
  name                 = "DB_sub"
  resource_group_name  = azurerm_virtual_network.jwh_vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.jwh_vnet.name
  address_prefixes     = ["192.168.3.0/24"]

  enforce_private_link_endpoint_network_policies = true
}

#Bastion_서브넷
resource "azurerm_subnet" "BS_sub" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_virtual_network.jwh_vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.jwh_vnet.name
  address_prefixes     = ["192.168.4.0/24"]
}

#was_img_서브넷
resource "azurerm_subnet" "was_img_sub" {
  name                 = "was_img_sub"
  resource_group_name  = azurerm_virtual_network.jwh_vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.jwh_vnet.name
  address_prefixes     = ["192.168.5.0/24"]
}