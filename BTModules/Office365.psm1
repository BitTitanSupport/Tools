# Set strict mode.
Set-StrictMode -Version 2.0

# Disable progress bar.
$ProgressPreference = "SilentlyContinue"

# Set default ErrorAction to Stop.
$ErrorActionPreference = "Stop"

################################################################################
# Clear all opened PSSessions.
################################################################################
function Clear-PSSession
{
    try
    {
        DisplayInProgressOperation "Remove PSSessions"
        Get-PSSession | Remove-PSSession
        DisplayCompletedOperation "OK" Green
    }
    catch
    {
        DisplayCompletedOperation "FAIL" Red
        Write-Host -ForegroundColor Red "ERROR: Clear-PSSession failed with $_"
        return $false
    }
}

################################################################################
# Connect to Office 365
################################################################################
function Connect-Office365($credentials)
{
    # Connect to MsolService
    try
    {
        DisplayInProgressOperation "Connect to MsolService"
        Connect-MsolService -Credential $credentials
        DisplayCompletedOperation "OK" Green
    }
    catch
    {
        DisplayCompletedOperation "FAIL" Red
        Write-Host -ForegroundColor Red "ERROR: Connect-MsolService failed with $_"
        return $false
    }

    # Create new PSSession
    try
    {
        DisplayInProgressOperation "Create New-PSSession"
        $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credentials -Authentication Basic -AllowRedirection
        DisplayCompletedOperation "OK" Green
    }
    catch
    {
        DisplayCompletedOperation "FAIL" Red
        Write-Host -ForegroundColor Red "ERROR: New-PSSession failed with $_"
        return $false
    }

    # Import the session
    try
    {
        DisplayInProgressOperation "Import PSSession"
        Import-PSSession $session -AllowClobber -DisableNameChecking | Out-Null
        DisplayCompletedOperation "OK" Green
    }
    catch
    {
        DisplayCompletedOperation "FAIL" Red
        Write-Host -ForegroundColor Red "ERROR: Import-PSSession failed with $_"
        return $false
    }
    
    return $session    
}

################################################################################
# Get all users from Office 365
################################################################################
function Get-Office365Users
{
    try
    {
        DisplayInProgressOperation "Get All Office 365 Users"
        $users = Get-MsolUser
        DisplayCompletedOperation "OK" Green
        return $users
    }
    catch
    {
        DisplayCompletedOperation "FAIL" Red
        Write-Host -ForegroundColor Red "ERROR: Get-MsolUser failed with $_"
        return $false
    }
}

################################################################################
# Remove a user from Office 365
################################################################################
function Remove-Office365User($user)
{
    try
    {
        DisplayInProgressOperation "Removing $($user.UserPrincipalName)"
        Remove-MsolUser -UserPrincipalName $user.UserPrincipalName -Force
        DisplayCompletedOperation "OK" Green
        return $true
    }
    catch
    {
        DisplayCompletedOperation "FAIL" Red
        Write-Host -ForegroundColor Red "ERROR: Remove-MsolUser failed with $_"
        return $false
    }
}

############################################################
# Create a new user in Office 365
############################################################
function New-Office365User($email, $firstName, $lastName, $sku, $defaultPassword)
{
    try
    {
        $displayName = "$firstName $lastName"
        DisplayInProgressOperation "Creating $email"
        New-MsolUser -DisplayName $displayName -FirstName $firstName -LastName $lastName -UserPrincipalName $email -UsageLocation "US" -LicenseAssignment $sku -Password $defaultPassword -ForceChangePassword $false | Out-Null
        DisplayCompletedOperation "OK" Green
    }
    catch
    {
        DisplayCompletedOperation "FAIL" Red
        Write-Host -ForegroundColor Red "ERROR: New-MsolUser failed with $_"
        return $false
    }
}

############################################################
# Test if a Tenant is Dehydrated
############################################################
function Test-IsTenantDehydrated()
{
    try
    {
        DisplayInProgressOperation "Test if the tenant is dehydrated"
        $isDehydrated = $(Get-OrganizationConfig | Select-Object -ExpandProperty IsDehydrated)
        DisplayCompletedOperation "OK" Green
        return $isDehydrated
    }
    catch
    {
        DisplayCompletedOperation "FAIL" Red
        Write-Host -ForegroundColor Red "ERROR: Get-OrganizationConfig failed with $_"
        return $null
    }
}

############################################################
# Test if a user had Impersonation Rights
############################################################
function Test-HasImpersonationRights($username)
{
    try
    {
        DisplayInProgressOperation "Test if Admin has Impersonation rights"
        $hasImpersonationRights = [Bool](Get-ManagementRoleAssignment -Role "ApplicationImpersonation" -RoleAssigneeType User -RoleAssignee $username)
        DisplayCompletedOperation "OK" Green
        return $hasImpersonationRights
    }
    catch
    {
        DisplayCompletedOperation "FAIL" Red
        Write-Host -ForegroundColor Red "ERROR: Get-ManagementRoleAssignment failed with $_"
        return $null
    }
}

############################################################
# Enable OrganizationCustomization for the tenant if not hydrated
############################################################
function Enable-TenantCustomization()
{
    try
    {
        DisplayInProgressOperation "Enable OrganizationCustomization"
        Enable-OrganizationCustomization -ErrorAction silentlycontinue
        DisplayCompletedOperation "OK" Green
        return $true
    }
    catch
    {
        DisplayCompletedOperation "FAIL" Red
        Write-Host -ForegroundColor Red "ERROR: Enable-OrganizationCustomization failed with $_"
        return $false
    }
}

############################################################
# Add Impersonation Rights to a user
############################################################
function Add-ImpersonationRights($username)
{
    try
    {
        DisplayInProgressOperation "Set Impersonation rights"
        New-ManagementRoleAssignment -Role "ApplicationImpersonation" -User  $username
        DisplayCompletedOperation "OK" Green
        return $true
    }
    catch
    {
        DisplayCompletedOperation "FAIL" Red
        Write-Host -ForegroundColor Red "ERROR: Set-ManagementRoleAssignment failed with $_"
        return $false
    }
}