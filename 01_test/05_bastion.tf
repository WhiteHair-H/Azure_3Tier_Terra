# Bastion 생성
# Bastion 공용IP 연결
resource "azurerm_public_ip" "jwh_bsh_pub" {
  name                = "jwh_bsh_pub"
  location            = azurerm_resource_group.jwh_rg.location
  resource_group_name = azurerm_resource_group.jwh_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "jwh_bsh_host" {
  name                = "jwh_bsh_host"
  location            = azurerm_resource_group.jwh_rg.location
  resource_group_name = azurerm_resource_group.jwh_rg.name

  ip_configuration {
    name                 = "AzureBastionHost"
    subnet_id            = azurerm_subnet.BS_sub.id
    public_ip_address_id = azurerm_public_ip.jwh_bsh_pub.id
  }
}
