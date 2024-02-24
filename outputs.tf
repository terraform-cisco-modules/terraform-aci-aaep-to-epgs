/*_____________________________________________________________________________________________________________________

AAEP to EPG — Outputs
_______________________________________________________________________________________________________________________
*/
output "aaep_to_epgs" {
  description = "Map of AAEP to EPG Settings."
  value       = { for k in sort(keys(aci_epgs_using_function.epg_to_aaeps)) : k => aci_epgs_using_function.epg_to_aaeps[k].id }
}
