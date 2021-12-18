# ssh-key 발급
resource "azurerm_ssh_public_key" "jwh_key" {
  name                = "jwh_key"
  resource_group_name = azurerm_resource_group.jwh_rg.name
  location            = azurerm_resource_group.jwh_rg.location
  public_key          = file("../../.ssh/id_rsa.pub")
}
