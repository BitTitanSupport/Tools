# Progress indicator
$ProgressPreference = "SilentlyContinue"

# Set strict mode.
Set-StrictMode -Version 2.0
 
# Set default ErrorAction to Stop.
$ErrorActionPreference = "Stop"

#Import GetDevConsole Module
Try
{
    $scriptPath = $script:MyInvocation.MyCommand.Path
    $scriptDirectory = Split-Path $scriptPath

    Import-Module "$scriptDirectory\GetDevConsole.psm1" -Force -DisableNameChecking
    Import-Module "$scriptDirectory\InstallDevConsole.psm1" -Force -DisableNameChecking
    Import-Module "$scriptDirectory\..\BTModules\BTSupport.psm1" -Force -DisableNameChecking
}
Catch
{
    Write-Host "Failed to import required modules: Breaking script" -ForegroundColor Red
    exit
}

$installationStatus = Install-DevConsole

if ($true -eq $installationStatus)
{
    Write-Host -ForegroundColor Green -Object "DevConsole was successfully installed"
}
else
{
    Write-Host -ForegroundColor Red -Object "DevConsole failed to install"
}