locals {
  vlan_ranges_l1 = [
    for v in var.attachable_access_entity_profiles : {
      access_vlan               = v.access_vlan
      instrumentation_immediacy = v.instrumentation_immediacy
      name                      = v.name
      vlan_split = length(regexall("-", v.allowed_vlans)) > 0 ? tolist(split(",", v.allowed_vlans)) : length(
        regexall(",", v.allowed_vlans)) > 0 ? tolist(split(",", v.allowed_vlans)
      ) : [v.allowed_vlans]
      vlan_range = v.allowed_vlans
    }
  ]
  vlan_ranges_l2 = [
    for v in local.vlan_ranges_l1 : {
      access_vlan               = tonumber(v.access_vlan)
      instrumentation_immediacy = v.instrumentation_immediacy
      name                      = v.name
      vlan_list = (length(regexall("(,|-)", jsonencode(v.vlan_range))) > 0 ? flatten([
        for s in v.vlan_split : length(regexall("-", s)) > 0 ? [for v in range(tonumber(
          element(split("-", s), 0)), (tonumber(element(split("-", s), 1)) + 1)
        ) : tonumber(v)] : [s]
      ]) : v.vlan_split)
    }
  ]
  aaeps_to_vlans = { for i in flatten([
    for v in local.vlan_ranges_l2 : [
      for e in v.vlan_list : {
        instrumentation_immediacy = v.instrumentation_immediacy
        mode                      = v.access_vlan == e ? "access" : "trunk"
        name                      = v.name
        vlan                      = tonumber(e)
      }
    ]
  ]) : "${i.name}:${i.vlan}" => i }
  epgs = flatten([
    for v in var.tenants : [
      for e in v.application_profiles : [
        for i in e.application_epgs : {
          application_epg     = element(split(",", i), 0)
          application_profile = e.name
          tenant              = v.name
          vlans = length(split(",", i)) == 3 ? [
            tonumber(element(split(",", i), 1)), tonumber(element(split(",", i), 2))
          ] : [tonumber(element(split(",", i), 1))]
        }
      ]
    ]
  ])
  aaeps_to_epgs = { for i in flatten([
    for k, v in local.aaeps_to_vlans : [
      for e in local.epgs : {
        app_epg                   = e.application_epg
        app_profile               = e.application_profile
        epg_dn                    = "uni/tn-${e.tenant}/ap-${e.application_profile}/epg-${e.application_epg}"
        instrumentation_immediacy = v.instrumentation_immediacy
        mode                      = v.mode
        name                      = v.name
        tenant                    = e.tenant
        vlans                     = [for i in e.vlans : tostring(i)]
      } if v.vlan == element(e.vlans, 0)
    ]
  ]) : "${i.name}:${i.tenant}:${i.app_profile}:${i.app_epg}" => i }
}