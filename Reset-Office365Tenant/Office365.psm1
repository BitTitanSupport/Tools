# Set strict mode.
Set-StrictMode -Version 2.0

# Disable progress bar.
$ProgressPreference ="SilentlyContinue"

# Set default ErrorAction to Stop.
$ErrorActionPreference = "Stop"

################################################################################
# Display InProgress Operation
################################################################################
function DisplayInProgressOperation($text)
{
    Write-Host -NoNewLine ("{0,-50} " -f $text)
}

################################################################################
# Display Completed Operation
################################################################################
function DisplayCompletedOperation($text, $color)
{
    Write-Host -ForegroundColor $color "[ $text ]"
}

################################################################################
# Clear all opened PSSessions.
################################################################################
function Clear-PSSession
{
    try
    {
        DisplayInProgressOperation "Remove PSSessions"
        Get-PSSession | Remove-PSSession
        Write-Host -ForegroundColor Green " [ OK ]"
    }
    catch
    {
        Write-Host -ForegroundColor Red " [ FAIL ]"
        Write-Host -ForegroundColor Red "ERROR: Clear-PSSession failed with $_"
        return 0;
    }
    
}

################################################################################
# Connect to Office 365
################################################################################
function Connect-Office365($credentials)
{
    try
    {
        DisplayInProgressOperation "Connect to MsolService"
        Connect-MsolService -Credential $credentials
        Write-Host -ForegroundColor Green " [ OK ]"
    }
    catch
    {
        Write-Host -ForegroundColor Red " [ FAIL ]"
        Write-Host -ForegroundColor Red "ERROR: Connect-MsolService failed with $_"
        return $null;
    }

    # Create new PSSession
    try
    {
        DisplayInProgressOperation "Create New-PSSession"
        $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credentials -Authentication Basic -AllowRedirection
        Write-Host -ForegroundColor Green " [ OK ]"
    }
    catch
    {
        Write-Host -ForegroundColor Red " [ FAIL ]"
        Write-Host -ForegroundColor Red "ERROR: New-PSSession failed with $_"
        return $null;
    }
    
    return $session    
}

################################################################################
# Reset-Office365Tenant
################################################################################
function Reset-Office365Tenant($credentials)
{
    if ($null -eq $credentials)
    {
        Write-Host "Ask for credentials"
        $credentials = Get-Credentials -Message "Please insert your Office365 Admin Credentials" 
    }
    else
    {
        Write-Host "Credentials supplied"
    }

    # Clean all PSSessions
    Clear-PSSession

    $session = Connect-Office365 -credentials $credentials
    if ($null -ne $session)
    {
        Remove-Office365Users
    }
}