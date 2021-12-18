# 리소스 그룹
# 한국 중부 설정
resource "azurerm_resource_group" "jwh_rg" {
  name     = "jwh_rgrg"
  location = "koreacentral"
}
