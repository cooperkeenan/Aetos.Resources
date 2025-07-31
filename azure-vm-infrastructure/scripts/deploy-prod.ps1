$ErrorActionPreference = "Stop"

Write-Host "Deploying Prod Environment..." -ForegroundColor Green

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location "$scriptPath\..\environments\prod"

Write-Host "Initializing Terraform..." -ForegroundColor Yellow
terraform init

Write-Host "Planning deployment..." -ForegroundColor Yellow
terraform plan

Write-Host "Applying deployment..." -ForegroundColor Yellow
terraform apply

Write-Host "Prod environment deployed!" -ForegroundColor Green
Write-Host "Check outputs above for connection details." -ForegroundColor Yellow
