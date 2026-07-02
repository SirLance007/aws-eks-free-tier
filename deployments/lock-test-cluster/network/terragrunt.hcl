include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules//network"
}

locals {
  secret_tfvars_file = "./secrets.json"
  
  # Read parent terraform.tfvars safely
  tfvars = merge(
     jsondecode(read_tfvars_file("../terraform.tfvars")),
     fileexists(local.secret_tfvars_file) ? jsondecode(read_tfvars_file(local.secret_tfvars_file)) : {}
  )
}

inputs = local.tfvars
