# Was_img 가상머신 공용IP설정
resource "azurerm_public_ip" "jwh_pub_was_ip" {
  name                = "jwh_pub_was_ip"
  resource_group_name = azurerm_resource_group.jwh_rg.name
  location            = azurerm_resource_group.jwh_rg.location
  allocation_method   = "Static"
  availability_zone   = 1
  sku                 = "Standard"
}

# Was_img 가상머신 서브넷 인터페이스 생성
resource "azurerm_network_interface" "jwh_was_vm_img_nif" {
  name                = "jwh_was_vm_img_nif"
  location            = azurerm_resource_group.jwh_rg.location
  resource_group_name = azurerm_resource_group.jwh_rg.name

  ip_configuration {
    name                          = "was_vm_pub"
    subnet_id                     = azurerm_subnet.was_img_sub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jwh_pub_was_ip.id
  }

  depends_on = [
    azurerm_public_ip.jwh_pub_was_ip
  ]
}

##### Was img 가상머신 #####
resource "azurerm_linux_virtual_machine" "jwh_was_img_vm" {
  name                  = "jwh_was_img_vm"
  location              = azurerm_resource_group.jwh_rg.location
  resource_group_name   = azurerm_resource_group.jwh_rg.name
  network_interface_ids = [azurerm_network_interface.jwh_was_vm_img_nif.id]
  zone                  = 1
  size                  = "Standard_DS1_v2"
  admin_username        = "haha"
  computer_name         = "wasvm"

  admin_ssh_key {
    username   = "haha"
    public_key = file("../../.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    name                 = "jwh_was_vm_disk"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.jwh_was_vm_img_nif
  ]
}

# was img petclinic install
resource "azurerm_virtual_machine_extension" "jwh_was_img_vm_ex" {
  name                 = "jwh_was_img_vm_ex"
  virtual_machine_id   = azurerm_linux_virtual_machine.jwh_was_img_vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
  {
      "script": "${filebase64("petclinic.sh")}"
  }
  SETTINGS

  depends_on = [
    azurerm_linux_virtual_machine.jwh_was_img_vm
  ]
}

# 이미지 갤러리 생성
resource "azurerm_shared_image_gallery" "was_img_gal" {
  name                = "was_img_gal"
  resource_group_name = azurerm_resource_group.jwh_rg.name
  location            = azurerm_resource_group.jwh_rg.location

  depends_on = [
    azurerm_virtual_machine_extension.jwh_was_img_vm_ex
  ]
}

# 공유 이미지 생성
resource "azurerm_shared_image" "was_img_sh" {
  name                = "was_img_sh"
  gallery_name        = azurerm_shared_image_gallery.was_img_gal.name
  resource_group_name = azurerm_resource_group.jwh_rg.name
  location            = azurerm_resource_group.jwh_rg.location
  os_type             = "Linux"
  specialized         = true

  identifier {
    publisher = "jwh_pub"
    offer     = "jwh_name"
    sku       = "jwh_sku"
  }

  depends_on = [
    azurerm_shared_image_gallery.was_img_gal
  ]
}

# 공유이미지 버전 설정
resource "azurerm_shared_image_version" "was_img_v" {
  name                = "0.0.1"
  gallery_name        = azurerm_shared_image_gallery.was_img_gal.name
  resource_group_name = azurerm_resource_group.jwh_rg.name
  location            = azurerm_resource_group.jwh_rg.location
  image_name          = azurerm_shared_image.was_img_sh.name
  managed_image_id    = azurerm_linux_virtual_machine.jwh_was_img_vm.id

  target_region {
    name                   = azurerm_resource_group.jwh_rg.location
    regional_replica_count = 1
  }

  depends_on = [
    azurerm_shared_image.was_img_sh
  ]
}
