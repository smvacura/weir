$ErrorActionPreference = "Stop"

$basePaths = @(
    "../weir/parser/test/test_plans",
    "../weir/engine/test/test_plans",
    "../weir/engine/bench/test_plans"
)
$providersSrc = Join-Path $PWD "providers.tf"

$basePaths | ForEach-Object { Get-ChildItem -Path $_ -Directory } | ForEach-Object {
    if (Test-Path (Join-Path $_.FullName "plan.json")) {
        Write-Host "Skipping $($_.FullName) (plan.json already exists)"
        return
    }
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