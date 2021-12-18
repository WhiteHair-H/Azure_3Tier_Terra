# 보안그룹
# Web Port 80
# Was Port 8080
# DB Port All
# Was_img Port 80, 8080

# Web 보안그룹
# Port 80
resource "azurerm_network_security_group" "jwh_nsg_web" {
  name                = "jwh_nsg_web"
  location            = azurerm_resource_group.jwh_rg.location
  resource_group_name = azurerm_resource_group.jwh_rg.name

  security_rule {
    name                       = "web-http-rule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80" , "22"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  depends_on = [
    azurerm_subnet.WEB_sub
  ]
}

# Web security group과 web subnet 합침
resource "azurerm_subnet_network_security_group_association" "jwh_nsgass_web" {
  subnet_id                 = azurerm_subnet.WEB_sub.id
  network_security_group_id = azurerm_network_security_group.jwh_nsg_web.id
  depends_on = [
    azurerm_network_security_group.jwh_nsg_web
  ]
}

# Was 보안그룹
# Port 8080
resource "azurerm_network_security_group" "jwh_nsg_was" {
  name                = "jwh_nsg_was"
  location            = azurerm_resource_group.jwh_rg.location
  resource_group_name = azurerm_resource_group.jwh_rg.name

  security_rule {
    name                       = "was-tomcat-rule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges     = ["8080" , "22"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  depends_on = [
    azurerm_subnet.WAS_sub
  ]
}

# Was security group과 was subnet 합침
resource "azurerm_subnet_network_security_group_association" "jwh_nsgass_was" {
  subnet_id                 = azurerm_subnet.WAS_sub.id
  network_security_group_id = azurerm_network_security_group.jwh_nsg_was.id
  depends_on = [
    azurerm_network_security_group.jwh_nsg_was
  ]
}

# DB 보안그룹
# All
resource "azurerm_network_security_group" "jwh_nsg_db" {
  name                = "jwh_nsg_db"
  location            = azurerm_resource_group.jwh_rg.location
  resource_group_name = azurerm_resource_group.jwh_rg.name

  security_rule {
    name                       = "db-rule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  depends_on = [
    azurerm_subnet.DB_sub
  ]
}

# DB security group과 DB subnet 합침
resource "azurerm_subnet_network_security_group_association" "jwh_nsgass_db" {
  subnet_id                 = azurerm_subnet.DB_sub.id
  network_security_group_id = azurerm_network_security_group.jwh_nsg_db.id
  depends_on = [
    azurerm_network_security_group.jwh_nsg_db
  ]
}

# Was_img 보안그룹
# 80, 8080
resource "azurerm_network_security_group" "jwh_nsg_was_img" {
  name                = "jwh_nsg_was_img"
  location            = azurerm_resource_group.jwh_rg.location
  resource_group_name = azurerm_resource_group.jwh_rg.name

  security_rule {
    name                       = "was-rule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80" , "8080" , "22"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  depends_on = [
    azurerm_subnet.was_img_sub
  ]
}

# Was_img security group과 Was_img subnet 합침
resource "azurerm_subnet_network_security_group_association" "jwh_nsgass_was_img" {
  subnet_id                 = azurerm_subnet.was_img_sub.id
  network_security_group_id = azurerm_network_security_group.jwh_nsg_was_img.id
  depends_on = [
    azurerm_network_security_group.jwh_nsg_was_img
  ]
}