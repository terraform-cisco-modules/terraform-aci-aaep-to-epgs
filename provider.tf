terraform {
  required_version = ">= 1.3.6"
  required_providers {
    aci = {
      source  = "ciscodevnet/aci"
      version = ">= 2.6.1"
    }
  }
}
