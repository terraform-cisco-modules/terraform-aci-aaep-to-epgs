/*_____________________________________________________________________________________________________________________

ACI Provider Settings
_______________________________________________________________________________________________________________________
*/
variable "apicHostname" {
  default     = "apic.example.com"
  description = "Cisco APIC Hostname"
  type        = string
}

variable "apicPass" {
  default     = "dummydummy"
  description = "Password for User based Authentication."
  sensitive   = true
  type        = string
}

variable "apicUser" {
  default     = "admin"
  description = "Username for User based Authentication."
  type        = string
}

variable "certName" {
  default     = ""
  description = "Cisco ACI Certificate Name for SSL Based Authentication"
  sensitive   = true
  type        = string
}

variable "privateKey" {
  default     = ""
  description = "Cisco ACI Private Key for SSL Based Authentication."
  sensitive   = true
  type        = string
}

variable "apic_version" {
  default     = "5.2(4e)"
  description = "The Version of ACI Running in the Environment."
  type        = string
}


/*_____________________________________________________________________________________________________________________

Access -> Global -> Attachable Access Entity Profiles
_______________________________________________________________________________________________________________________
*/

variable "attachable_access_entity_profiles" {
  description = <<-EOT
    * access_vlan: (optional) Access/Native VLAN ID.
    * allowed_vlans: List of VLAN's to Attach to the Attachable Access Entity Profile.
    * instrumentation_immediacy:  Instrumentation immediacy.
        - immediate 
        - on-demand (default)
    * name: Name of the Attachable Access Entity Profile.
  EOT
  type = list(object(
    {
      access_vlan               = optional(number, 1)
      allowed_vlans             = string
      instrumentation_immediacy = optional(string, "on-demand")
      name                      = string
    }
  ))
}

/*_____________________________________________________________________________________________________________________

Tenants -> {tenant_name} -> Application Profiles -> {app_name} -> Application EPGs: {name}
_______________________________________________________________________________________________________________________
*/

variable "tenants" {
  description = <<-EOT
    * application_profiles:
      - application_epgs: List of application_epgs with vlans, like ["EPG1,1", "EPG11,11"].
      - name: Name of the Application Profile.
    * name: Name of the Tenant.
  EOT
  type = list(object(
    {
      application_profiles = list(object(
        {
          application_epgs = list(string)
          name             = string
        }
      ))
      name = string
    }
  ))
}
