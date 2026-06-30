pid_file = "./vault-agent.pid"

vault {
   address = "${env:VAULT_ADDR}"
}

auto_auth {
  method {
    type = "jwt"
    config = {
       token = "${env:VAULT_JWT_TOKEN}"
       role = "gitlab-ci"
    }
  }

  exit_after_auth_failure = true
  exit_after_auth_retry_duration = "60s"
}

# Template to fetch secret inputs from Vault and write to secrets.json
template {
  source      = "${env:CI_PROJECT_DIR}/.gitlab/ci/vault-template/tfvars.tpl"
  destination = "${env:CI_PROJECT_DIR}/${env:DEPLOYMENT_PATH}/secrets.json"
  perms       = "600"
  error_on_missing_key = true
}

# Template to fetch temporary AWS credentials and write to environment variables file
template {
  source      = "${env:CI_PROJECT_DIR}/.gitlab/ci/vault-template/aws-auth.tpl"
  destination = "/tmp/aws-creds.env"
  perms       = "600"
  error_on_missing_key = true
}

exit_after_auth = true
