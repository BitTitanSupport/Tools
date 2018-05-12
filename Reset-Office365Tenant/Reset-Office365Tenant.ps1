param(
    [Parameter(Mandatory=$True)]
    [PSCredential] $credentials,
    [Parameter(Mandatory=$True)]
    [string] $defaultPassword
) 

# Set strict mode.
Set-StrictMode -Version 2.0

# Disable progress bar.
$ProgressPreference ="SilentlyContinue"

# Set default ErrorAction to Stop.
$ErrorActionPreference = "Stop"

#Import-Module
Import-Module ".\Office365.psm1" -Force -DisableNameChecking

Reset-Office365Tenant -credentials $credentials