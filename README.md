# Template Repo for Terraform Modules

This repo provides a template for creating Terraform Modules. For information on how to create a repo from this template see the [GitHub docs](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/creating-a-repository-from-a-template)

## Contents
This repo contains,

1. An Apache 2.0 default license with a copyright statement under Hypr
1. Default .gitignore
1. Default .gitattributes which provides line ending consistency across OS's

## Naming convention

Follow this naming convention for Terraform Module repo's

Terraform-{provider}-{resource-name}-module

Where
 * provider is the cloud provider of the resource (e.g. `aws`, `azure`, `gcp`, `github`)
 * resource-name is the name of the resource