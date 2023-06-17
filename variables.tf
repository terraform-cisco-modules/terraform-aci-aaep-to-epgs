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
    application_profiles:
      application_epgs: List of application_epgs with vlans, like ["EPG1,1", "EPG11,11"].
      name: Name of the Application Profile.
    name: Name of the Tenant.
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
