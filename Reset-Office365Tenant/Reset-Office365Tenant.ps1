param(
    [Parameter(Mandatory=$false)]
    [PSCredential] $credentials,
    [Parameter(Mandatory=$true)]
    [string] $defaultPassword,
    [Parameter(Mandatory=$false)]
    [int] $maxUser = 20
) 

# Set strict mode.
Set-StrictMode -Version 2.0

# Disable progress bar.
$ProgressPreference ="SilentlyContinue"

# Set default ErrorAction to Stop.
$ErrorActionPreference = "Stop"

#Import-Module
Import-Module ".\Office365.psm1" -Force -DisableNameChecking

$rc = Reset-Office365Tenant -credentials $credentials -defaultPassword $defaultPassword -maxUser $maxUser

if ($true -eq $rc)
{
    Write-Host -ForegroundColor Green "Tenant reset Successfully."
}
else
{
    Write-Host -ForegroundColor Red "Tenant reset Failed."
}
