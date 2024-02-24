locals {
  #__________________________________________________________
  #
  # Model Inputs
  #__________________________________________________________
  controller    = var.model.global_settings.controller
  defaults      = yamldecode(file("${path.module}/defaults.yaml")).defaults.tenants
  npfx          = merge(local.defaults.name_prefix, lookup(var.model, "name_prefix", {}))
  nsfx          = merge(local.defaults.name_suffix, lookup(var.model, "name_suffix", {}))
  networking    = lookup(var.model, "networking", {})
  template_bds  = lookup(lookup(var.model, "templates", {}), "bridge_domains", {})
  template_epgs = lookup(lookup(var.model, "templates", {}), "application_epgs", {})
  # Defaults
  app = local.defaults.application_profiles
  epg = local.app.application_epgs

  #__________________________________________________________
  #
  # Bridge Domain Variables
  #__________________________________________________________

  bds_with_template = [
    for v in lookup(local.networking, "bridge_domains", []) : {
      name     = v.name
      template = lookup(v, "template", "")
    } if lookup(v, "template", "") != ""
  ]
  merge_bds_template = { for i in flatten([
    for v in local.bds_with_template : [
      merge(local.networking.bridge_domains[index(local.networking.bridge_domains[*].name, v.name)
      ], local.template_bds[index(local.template_bds[*].template_name, v.template)])
    ] if length(local.template_bds) > 0
  ]) : i.name => i }
  bds        = { for v in lookup(local.networking, "bridge_domains", []) : v.name => v }
  merged_bds = merge(local.bds, local.merge_bds_template)
  bridge_domains = {
    for k, v in local.merged_bds : "${local.npfx.bridge_domains}${v.name}${local.nsfx.bridge_domains}" => {
      application_epg = lookup(v, "application_epg", {})
      name            = "${local.npfx.bridge_domains}${v.name}${local.nsfx.bridge_domains}"
      tenant          = var.tenant
    }
  }


  #__________________________________________________________
  #
  # Application Profile(s) and Endpoint Group(s) - Variables
  #__________________________________________________________

  application_profiles = {
    for v in lookup(var.model, "application_profiles", {}
      ) : "${local.npfx.application_profiles}${v.name}${local.nsfx.application_profiles}" => merge(
      local.app, v,
      {
        application_epgs = lookup(v, "application_epgs", [])
        name             = "${local.npfx.application_profiles}${v.name}${local.nsfx.application_profiles}"
        tenant           = var.tenant
      }
    )
  }
  bd_with_epgs = flatten([
    for k, v in local.bridge_domains : [
      for e in [v.application_epg] : {
        application_epg = e
        name            = k
        template        = lookup(e, "template", "")
      } if length(v.application_epg) > 0
    ]
  ])
  bd_to_epg = { for i in flatten([
    for v in local.bd_with_epgs : [
      merge(
        local.bridge_domains[v.name],
        local.template_epgs[index(local.template_epgs[*].template_name, v.template)], {
          application_profile = v.application_epg.application_profile
          bridge_domain       = v.name
          name                = replace(replace(v.name, local.npfx.bridge_domains, ""), local.nsfx.bridge_domains, "")
          vlans               = lookup(v.application_epg, "vlans", [])
        }
      )
    ]
  ]) : i.name => i }
  epgs = { for i in flatten([
    for value in local.application_profiles : [
      for v in value.application_epgs : merge(v, { application_profile = value.name })
    ] if length(value.application_epgs) > 0
  ]) : i.name => i }
  epgs_with_template = [
    for k, v in local.epgs : {
      name     = k
      template = lookup(v, "template", "")
    } if length(compact([lookup(v, "template", "")])) > 0
  ]
  merge_templates = { for i in flatten([
    for v in local.epgs_with_template : [
      merge(local.template_epgs[index(local.template_epgs[*].template_name, v.template)], local.epgs[v.name])
    ]
  ]) : i.name => i }
  merged_epgs = merge(local.bd_to_epg, local.epgs, local.merge_templates)
  application_epgs = { for i in flatten([
    for k, v in local.merged_epgs : merge(local.epg, v, {
      application_profile = "${local.npfx.application_profiles}${v.application_profile}${local.nsfx.application_profiles}"
      bd = length(compact([lookup(v, "bridge_domain", "")])) > 0 ? {
        name = local.bridge_domains[v.bridge_domain].name
      } : { name = "" }
      name   = "${local.npfx.application_epgs}${v.name}${local.nsfx.application_epgs}"
      tenant = var.tenant
    })
  ]) : "${i.application_profile}/${i.name}" => i }

  aaep_to_epgs_loop = [
    for k, v in lookup(var.model, "aaep_to_epgs", []) : {
      aaep                      = v.name
      access                    = lookup(v, "access_or_native_vlan", 0)
      allowed_vlans             = lookup(v, "allowed_vlans", "")
      instrumentation_immediacy = lookup(v, "instrumentation_immediacy", "on-demand")
      mode = length(regexall("(,|-)", jsonencode(lookup(v, "allowed_vlans", "")))
      ) > 0 ? "trunk" : "native"
      vlan_split = length(regexall("-", lookup(v, "allowed_vlans", ""))
        ) > 0 ? tolist(split(",", lookup(v, "allowed_vlans", ""))) : length(
        regexall(",", lookup(v, "allowed_vlans", ""))) > 0 ? tolist(split(",", lookup(v, "allowed_vlans", ""))
      ) : [lookup(v, "allowed_vlans", "")]
    } if lookup(v, "access_or_native_vlan", 0) > 0 && length(compact([lookup(v, "allowed_vlans", "")])) > 0
  ]
  aaep_to_epgs_loop_2 = [for v in local.aaep_to_epgs_loop : merge(v, {
    vlan_list = length(regexall("(,|-)", jsonencode(v.allowed_vlans))) > 0 ? flatten([
      for s in v.vlan_split : length(regexall("-", s)) > 0 ? [for v in range(tonumber(
      element(split("-", s), 0)), (tonumber(element(split("-", s), 1)) + 1)) : tonumber(v)] : [tonumber(s)]
    ]) : [for s in v.vlan_split : tonumber(s)]
  })]
  epg_to_aaeps = { for i in flatten([
    for k, v in local.application_epgs : [
      for e in local.aaep_to_epgs_loop_2 : {
        aaep                      = e.aaep
        access                    = e.access
        application_epg           = v.name
        application_profile       = v.application_profile
        instrumentation_immediacy = e.instrumentation_immediacy
        key                       = k
        mode                      = contains(v.vlans, tonumber(e.access)) ? "native" : e.mode
        tdn                       = "uni/tn-${var.tenant}/ap-${v.application_profile}/epg-${v.name}"
        vlans                     = lookup(v, "vlans", [])
        } if length(v.vlans) == 2 ? contains(e.vlan_list, tonumber(element(v.vlans, 0))) && contains(
        e.vlan_list, tonumber(element(v.vlans, 1))) : length(v.vlans) == 1 ? contains(
        e.vlan_list, tonumber(element(v.vlans, 0))
      ) : false
    ] if v.epg_type == "standard"
  ]) : "${i.aaep}/${i.application_profile}/${i.application_epg}" => i }

}