#------------------------------------------------------
# Create Attachable Access Entity Generic Encap Policy
#------------------------------------------------------

/*_____________________________________________________________________________________________________________________

API Information:
 - Class: "infraAttEntityP"
 - Distinguished Name: "uni/infra/attentp-{AAEP}"
GUI Location:
 - Fabric > Access Policies > Policies > Global > Attachable Access Entity Profiles : {AAEP}
_______________________________________________________________________________________________________________________
*/
resource "aci_epgs_using_function" "epg_to_aaeps" {
  for_each          = { for k, v in local.epg_to_aaeps : k => v if local.controller.type == "apic" }
  access_generic_dn = "uni/infra/attentp-${each.value.aaep}/gen-default"
  encap             = length(each.value.vlans) > 0 ? "vlan-${element(each.value.vlans, 0)}" : "unknown"
  instr_imedcy      = each.value.instrumentation_immediacy == "on-demand" ? "lazy" : each.value.instrumentation_immediacy
  mode              = each.value.mode == "trunk" ? "regular" : each.value.mode == "access" ? "untagged" : "native"
  primary_encap     = length(each.value.vlans) > 1 ? "vlan-${element(each.value.vlans, 1)}" : "unknown"
  tdn               = each.value.tdn
}
