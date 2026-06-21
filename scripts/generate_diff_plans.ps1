$ErrorActionPreference = "Stop"

$basePath = "../weir/bin/test_plans"
$providersSrc = Join-Path $PWD "providers.tf"

Get-ChildItem -Path $basePath -Directory | ForEach-Object {
    $scenario = $_
    foreach ($side in @("before", "after")) {
        $dir = Join-Path $scenario.FullName $side
        if (Test-Path $dir -PathType Container) {
            if (Test-Path (Join-Path $dir "plan.json")) {
                Write-Host "Skipping $dir (plan.json already exists)"
                continue
            }
            Write-Host "Processing $dir"

            Copy-Item $providersSrc -Destination $dir

            Push-Location $dir

            terraform init
            terraform plan -out=tfplan
            terraform show -json tfplan | Out-File -FilePath plan.json -Encoding utf8

            Remove-Item -Recurse -Force .terraform, .terraform.lock.hcl, tfplan -ErrorAction SilentlyContinue
            Remove-Item providers.tf -ErrorAction SilentlyContinue

            Pop-Location
        }
    }
}
