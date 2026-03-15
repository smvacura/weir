#!/bin/bash

set -e

base_path="../parser/test/test_plans"
providers_src="$(pwd)/providers.tf"

for dir in "$base_path"/*; do
  if [ -d "$dir" ]; then
    echo "Processing $dir"
    
    cp "$providers_src" "$dir/"
    
    cd "$dir"
    
    terraform init
    terraform plan -out=tfplan
    terraform show -json tfplan > plan.json
    
    # Clean up
    rm -rf .terraform .terraform.lock.hcl tfplan
    rm -f providers.tf
    
    cd - > /dev/null
  fi
done