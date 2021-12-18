# # Web 가상머신
resource "azurerm_linux_virtual_machine" "jwh_web_vm" {
  name                  = "jwh_web_vm"
  location              = azurerm_resource_group.jwh_rg.location
  resource_group_name   = azurerm_resource_group.jwh_rg.name
  network_interface_ids = [azurerm_network_interface.jwh_web_vm_nif.id]
  zone                  = 1
  size                  = "Standard_DS1_v2"
  admin_username        = "haha"
  computer_name         = "webvm"

  admin_ssh_key {
    username   = "haha"
    public_key = file("../../.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    name                 = "jwh_web_vm_disk"
  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }
}
