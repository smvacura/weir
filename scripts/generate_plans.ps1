$ErrorActionPreference = "Stop"

$basePath = "../parser/test/test_plans"

Get-ChildItem -Path $basePath -Directory | ForEach-Object {
    Write-Host "Processing $($_.FullName)"
    
    Push-Location $_.FullName
    
    terraform init
    terraform plan -out=tfplan
    terraform show -json tfplan | Out-File -FilePath plan.json -Encoding utf8
    
    # Clean up
    Remove-Item -Recurse -Force .terraform, .terraform.lock.hcl, tfplan -ErrorAction SilentlyContinue
    
    Pop-Location
}