#Terraform Script
Write-Host "Formatting Terraform Code..."
terraform fmt
Write-Host "Validating Code..."
terraform validate
if ($LASTEXITCODE -ne 0) {
    Write-Host "Validation failed. Exiting script."
    exit 1
}
Write-Host "Planning Terraform changes..."
terraform plan
if ($LASTEXITCODE -ne 0) {
    Write-Host "Plan failed. Exiting script."
    exit 1
}
Write-Host "Applying Terraform changes..."
terraform apply -auto-approve
if ($LASTEXITCODE -ne 0) {
    Write-Host "Plan failed. Exiting script."
    exit 1
}