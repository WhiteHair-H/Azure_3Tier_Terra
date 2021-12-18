# Mysql server 생성
resource "azurerm_mysql_server" "jwh_dbserver" {
  name                         = "jwh-db"
  resource_group_name          = azurerm_resource_group.jwh_rg.name
  location                     = azurerm_resource_group.jwh_rg.location
  version                      = "5.7"
  administrator_login          = "haha"
  administrator_login_password = "It12345!"
  sku_name                     = "GP_Gen5_2"
  ssl_enforcement_enabled      = false
  storage_mb                   = 5120
}

# Mysql Database 생성
resource "azurerm_mysql_database" "jinwoo_db" {
  name                = "petclinic"
  resource_group_name = azurerm_resource_group.jwh_rg.name
  server_name         = azurerm_mysql_server.jwh_dbserver.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"

  depends_on = [
    azurerm_mysql_server.jwh_dbserver
  ]
}

# SQL Server Firewall rule 생성
resource "azurerm_mysql_firewall_rule" "jinwoo_db_firewall" {
  name                = "jinwoo_db_fire"
  resource_group_name = azurerm_resource_group.jwh_rg.name
  server_name         = azurerm_mysql_server.jwh_dbserver.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"

  depends_on = [
    azurerm_mysql_database.jinwoo_db
  ]
}

# Dns_zone 생성
resource "azurerm_private_dns_zone" "jwh_dns" {
  name                = "jwhmysql.com"
  resource_group_name = azurerm_resource_group.jwh_rg.name
}

# Dns_zone 가상 네트워크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "jwh_dns_vnet" {
  name                  = "jwh_dns_vnet"
  resource_group_name   = azurerm_resource_group.jwh_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.jwh_dns.name
  virtual_network_id    = azurerm_virtual_network.jwh_vnet.id
}

# Mysql Configuration
resource "azurerm_mysql_configuration" "jwh_db_conf" {
  resource_group_name = azurerm_resource_group.jwh_rg.name
  server_name         = azurerm_mysql_server.jwh_dbserver.name

  # mysql 서버 시간 맞추기
  name  = "time_zone"
  value = "+09:00"

  depends_on = [
    azurerm_mysql_database.jinwoo_db
  ]
}

# DB & DB_sub endpoint 생성
resource "azurerm_private_endpoint" "jwh_end" {
  name                = "jwh_end"
  location            = azurerm_resource_group.jwh_rg.location
  resource_group_name = azurerm_resource_group.jwh_rg.name
  subnet_id           = azurerm_subnet.DB_sub.id

  private_service_connection {
    name                           = "jwh_private_sc"
    private_connection_resource_id = azurerm_mysql_server.jwh_dbserver.id
    is_manual_connection           = false
    subresource_names              = ["mysqlServer"]
  }

  private_dns_zone_group {
    name                 = "private_dns_zone"
    private_dns_zone_ids = [azurerm_private_dns_zone.jwh_dns.id]
  }

  depends_on = [
    azurerm_mysql_firewall_rule.jinwoo_db_firewall
  ]
}
