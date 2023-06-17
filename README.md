<!-- BEGIN_TF_DOCS -->
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Developed by: Cisco](https://img.shields.io/badge/Developed%20by-Cisco-blue)](https://developer.cisco.com)

# Terraform ACI - AAEP to EPGs Module

A Terraform module to configure ACI Attachable Access Entity Profiles to EPG Mappings.

This module is part of the Cisco [*ACI as Code*](https://cisco.com/go/intersightascode) project. Its goal is to allow users to instantiate network fabrics in minutes using an easy to use, opinionated data model. It takes away the complexity of having to deal with references, dependencies or loops. By completely separating data (defining variables) from logic (infrastructure declaration), it allows the user to focus on describing the intended configuration while using a set of maintained and tested Terraform Modules without the need to understand the low-level Intersight object model.

A comprehensive example using this module is available here: https://github.com/terraform-cisco-modules/easy-aci-complete

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.6 |
| <a name="requirement_aci"></a> [aci](#requirement\_aci) | >= 2.6.1 |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aci"></a> [aci](#provider\_aci) | >= 2.6.1 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attachable_access_entity_profiles"></a> [attachable\_access\_entity\_profiles](#input\_attachable\_access\_entity\_profiles) | * access\_vlan: (optional) Access/Native VLAN ID.<br>* allowed\_vlans: List of VLAN's to Attach to the Attachable Access Entity Profile.<br>* instrumentation\_immediacy:  Instrumentation immediacy.<br>    - immediate <br>    - on-demand (default)<br>* name: Name of the Attachable Access Entity Profile. | <pre>list(object(<br>    {<br>      access_vlan               = optional(number, 1)<br>      allowed_vlans             = string<br>      instrumentation_immediacy = optional(string, "on-demand")<br>      name                      = string<br>    }<br>  ))</pre> | n/a | yes |
| <a name="input_tenants"></a> [tenants](#input\_tenants) | * application\_profiles:<br>  - application\_epgs: List of application\_epgs with vlans, like ["EPG1,1", "EPG11,11"].<br>  - name: Name of the Application Profile.<br>* name: Name of the Tenant. | <pre>list(object(<br>    {<br>      application_profiles = list(object(<br>        {<br>          application_epgs = list(string)<br>          name             = string<br>        }<br>      ))<br>      name = string<br>    }<br>  ))</pre> | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_epgs"></a> [epgs](#output\_epgs) | n/a |
## Resources

| Name | Type |
|------|------|
| [aci_epgs_using_function.epg_to_aaeps](https://registry.terraform.io/providers/ciscodevnet/aci/latest/docs/resources/epgs_using_function) | resource |
<!-- END_TF_DOCS -->