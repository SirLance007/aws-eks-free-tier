#!/usr/bin/env bash
set -euo pipefail

# Script directory lookup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/template"

# Display usage instructions
usage() {
    echo "Usage: $0 <deployment-name>"
    echo "Example: $0 my-free-cluster"
}

# Verify arguments
if [ $# -ne 1 ]; then
    usage
    exit 1
fi

DEPLOYMENT_NAME="$1"
DEPLOYMENT_DIR="${SCRIPT_DIR}/${DEPLOYMENT_NAME}"

# Ensure we don't overwrite an existing deployment
if [ -d "$DEPLOYMENT_DIR" ]; then
    echo "Error: Deployment folder '${DEPLOYMENT_NAME}' already exists!"
    exit 1
fi

echo "Creating new deployment directory at: ${DEPLOYMENT_DIR}"
mkdir -p "$DEPLOYMENT_DIR"

# Copy template files recursively
cp -r "${TEMPLATE_DIR}/." "${DEPLOYMENT_DIR}/"

# Utility function to handle Mac (BSD) and Linux (GNU) sed formatting in-place
sed_in_place() {
    local expression="$1"
    local file_path="$2"
    if sed --version >/dev/null 2>&1; then
        sed -i "$expression" "$file_path"
    else
        sed -i '' "$expression" "$file_path"
    fi
}

# Update the cluster_name variable to the chosen deployment name in the new folder
sed_in_place "s/^cluster_name[[:space:]]*=.*/cluster_name = \"${DEPLOYMENT_NAME}\"/" "${DEPLOYMENT_DIR}/terraform.tfvars"

echo "Success! Deployment folder created."
echo "Next steps:"
echo "  1. cd deployments/${DEPLOYMENT_NAME}"
2. Edit terraform.tfvars to customize your settings.
