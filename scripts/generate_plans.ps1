$ErrorActionPreference = "Stop"

$basePaths = @(
    "../azverify/parser/test/test_plans",
    "../azverify/engine/test/test_plans"
)
$providersSrc = Join-Path $PWD "providers.tf"

$basePaths | ForEach-Object { Get-ChildItem -Path $_ -Directory } | ForEach-Object {
    Write-Host "Processing $($_.FullName)"
    
    Copy-Item $providersSrc -Destination $_.FullName
    
    Push-Location $_.FullName
    
    terraform init
    terraform plan -out=tfplan
    terraform show -json tfplan | Out-File -FilePath plan.json -Encoding utf8
    
    # Clean up
    Remove-Item -Recurse -Force .terraform, .terraform.lock.hcl, tfplan -ErrorAction SilentlyContinue
    Remove-Item providers.tf -ErrorAction SilentlyContinue
    
    Pop-Location
}