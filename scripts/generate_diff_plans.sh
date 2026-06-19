#!/bin/bash

set -e

base_path="../weir/bin/test_plans"
providers_src="$(pwd)/providers.tf"

for scenario in "$base_path"/*/; do
  for side in before after; do
    dir="$scenario$side"
    if [ -d "$dir" ]; then
      echo "Processing $dir"

      cp "$providers_src" "$dir/"

      cd "$dir"

      terraform init
      terraform plan -out=tfplan
      terraform show -json tfplan > plan.json

      rm -rf .terraform .terraform.lock.hcl tfplan
      rm -f providers.tf

      cd - > /dev/null
    fi
  done
done
