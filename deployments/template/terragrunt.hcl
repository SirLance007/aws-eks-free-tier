include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "./"
}

locals {
  # Merge standard tfvars with secrets.json loaded from Vault Agent
  secret_tfvars_file = "./secrets.json"
  
  # Read existing files safely
  tfvars = merge(
     jsondecode(read_tfvars_file("./terraform.tfvars")),
     fileexists(local.secret_tfvars_file) ? jsondecode(read_tfvars_file(local.secret_tfvars_file)) : {}
  )
}

inputs = local.tfvars
