#!/bin/bash
set -e

# 1. Load deployment variables
if [ -f build.env ]; then
    source build.env
else
    echo "Error: build.env not found!"
    exit 1
fi

export DEPLOYMENT_NAME=$DEPLOYMENT_NAME
export DEPLOYMENT_PATH=$DEPLOYMENT_PATH
export ACCOUNT_NAME=$ACCOUNT_NAME

# Install Terragrunt
echo "Installing Terragrunt..."
curl -sLo /usr/local/bin/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v0.58.0/terragrunt_linux_amd64
chmod +x /usr/local/bin/terragrunt

# 2. Launch Vault Agent
echo "Launching Vault Agent..."
apk add --no-cache vault --repository=https://dl-cdn.alpinelinux.org/alpine/v3.20/community/ || apk add --no-cache vault || true
vault agent -config "$CI_PROJECT_DIR/.gitlab/ci/vault-template/vault-agent.hcl"

# 3. Source AWS credentials and destroy resources
echo "Sourcing temporary AWS credentials..."
if [ -f /tmp/aws-creds.env ]; then
    source /tmp/aws-creds.env
else
    echo "Error: /tmp/aws-creds.env not found!"
    exit 1
fi

cd "$DEPLOYMENT_PATH"
terragrunt destroy -auto-approve
