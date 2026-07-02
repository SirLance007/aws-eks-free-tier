include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules//compute"
}

dependency "network" {
  config_path = "../network"
}

locals {
  secret_tfvars_file = "./secrets.json"
  
  # Read parent terraform.tfvars safely
  tfvars = merge(
     jsondecode(read_tfvars_file("../terraform.tfvars")),
     fileexists(local.secret_tfvars_file) ? jsondecode(read_tfvars_file(local.secret_tfvars_file)) : {}
  )
}

inputs = merge(
  local.tfvars,
  {
    vpc_id     = dependency.network.outputs.vpc_id
    subnet_ids = dependency.network.outputs.public_subnet_ids
  }
)
