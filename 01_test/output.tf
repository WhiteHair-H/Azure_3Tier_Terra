output "Web_Subnet" {
    value = azurerm_subnet.WEB_sub.address_prefix
}

output "Was_Subnet" {
    value = azurerm_subnet.WAS_sub.address_prefix
}

output "DB_Subnet" {
    value = azurerm_subnet.DB_sub.address_prefix
}

output "Bastion_Subnet" {
    value = azurerm_subnet.BS_sub.address_prefix
}

output "Was_IMG_Subnet" {
    value = azurerm_subnet.was_img_sub.address_prefix
}

output "LB_Frontend_IP" {
  value = azurerm_public_ip.elb_pub.ip_address
  description = "Loadbalancer-Frontend-IP"
}

output "Web_VM_Private_IP" {
  value = azurerm_linux_virtual_machine.jwh_web_vm.private_ip_address
  description = "web_vm_private_ip_address"
}

# output "Was_VM_IMG_Public_IP" {
#   value = azurerm_linux_virtual_machine.jwh_was_img_vm.public_ip_address
#   description = "Was_VM_Image_PublicIP_address"
# }

# output "Was_VM_IMG_Private_IP" {
#   value = azurerm_linux_virtual_machine.jwh_was_img_vm.private_ip_address
#   description = "was_vm_private_ip_address"
# }