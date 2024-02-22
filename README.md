<!-- BEGIN_TF_DOCS -->
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Developed by: Cisco](https://img.shields.io/badge/Developed%20by-Cisco-blue)](https://developer.cisco.com)

# Terraform ACI - AAEP to EPGs Module

A Terraform module to configure ACI Tenant Policies.

### NOTE: THIS MODULE IS DESIGNED TO BE CONSUMED USING "EASY ACI"

### A comprehensive example using this module is available below:

## [Easy ACI](https://github.com/terraform-cisco-modules/easy-aci)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aci"></a> [aci](#requirement\_aci) | >=2.13.0 |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aci"></a> [aci](#provider\_aci) | >=2.13.0 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_model"></a> [model](#input\_model) | Model data. | `any` | n/a | yes |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | Name of the Tenant. | `any` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aaep_to_epgs"></a> [aaep\_to\_epgs](#output\_aaep\_to\_epgs) | Map of AAEP to EPG Settings. |
## Resources

| Name | Type |
|------|------|
| [aci_epgs_using_function.epg_to_aaeps](https://registry.terraform.io/providers/CiscoDevNet/aci/latest/docs/resources/epgs_using_function) | resource |
<!-- END_TF_DOCS -->