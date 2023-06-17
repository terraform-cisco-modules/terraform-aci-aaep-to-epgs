output "aaep_to_epgs" {
  description = "Map of AAEP to EPG Settings."
  value = [
    for k in sort(keys(local.aaeps_to_epgs)) : {
      aaep  = local.aaeps_to_epgs[k].name
      epg   = local.aaeps_to_epgs[k].epg_dn
      mode  = local.aaeps_to_epgs[k].mode
      vlans = local.aaeps_to_epgs[k].vlans
    }
  ]
}