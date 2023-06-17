terraform {
  required_version = ">= 1.3.6"
  required_providers {
    aci = {
      source  = "ciscodevnet/aci"
      version = ">= 2.6.1"
    }
  }
}

provider "aci" {
  cert_name   = var.certName
  password    = var.apicPass
  private_key = var.privateKey
  url         = "https://${var.apicHostname}"
  username    = var.apicUser
  insecure    = true
}
