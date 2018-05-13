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
    Write-Host -NoNewLine ("{0,-70} " -f $text)
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
        DisplayCompletedOperation "OK" Green
    }
    catch
    {
        DisplayCompletedOperation "FAIL" Red
        Write-Host -ForegroundColor Red "ERROR: Clear-PSSession failed with $_"
        return $false;
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
        return $false;
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
        return $false;
    }

    # Import the session
    try
    {
        DisplayInProgressOperation "Import PSSession"
        Import-PSSession $Session -AllowClobber -DisableNameChecking | Out-Null
        DisplayCompletedOperation "OK" Green
    }
    catch
    {
        DisplayCompletedOperation "FAIL" Red
        Write-Host -ForegroundColor Red "ERROR: Import-PSSession failed with $_"
        return 0;
    }
    
    return $session    
}

################################################################################
# Get-Office365Users
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
        return $false;
    }
}

################################################################################
# Remove-Office365User
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
        return $false;
    }
}

############################################################
# Create test user
############################################################
function New-Office365User($email, $firstName, $lastName, $sku, $defaultPassword)
{
    try
    {
        $displayName = "$firstName $lastName"
        DisplayInProgressOperation "Creating $Email"
        New-MsolUser -DisplayName $displayName -FirstName $firstName -LastName $lastName -UserPrincipalName $email -UsageLocation "US" -LicenseAssignment $sku -Password $defaultPassword -ForceChangePassword $false| Out-Null
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
# Create test users
############################################################
function New-Office365Users($max, $defaultPassword)
{
    # Gets the SKUs... we'll grab the first one - lazy
    try
    {
        $SKUs = Get-MsolAccountSku
    }
    catch
    {
        Write-Host -ForegroundColor Red "ERROR: Get-MsolAccountSku failed with $_"
        return $false
    }

    # Gets the Domains... we'll grab the first one - lazy
    try
    {
        $Domains = Get-MsolDomain
    }
    catch
    {
        Write-Host -ForegroundColor Red "ERROR: Get-MsolDomain failed with $_"
        return $false
    }

    # For each user we want to create.
    foreach ($number in 1..$max)
    {
        $firstName = "Test" -F $number
        $lastName  = "{0:D3}" -F $number
        $email     = "test{0:D3}@{1}" -F $number, $Domains[0].Name
        $sku       = $SKUs[0].AccountSkuId

        if ($false -eq $(New-Office365User -email $email -firstName $firstName -lastName $lastName -sku $sku -defaultPassword $defaultPassword))
        {
            return $false
        }
    }
    return $true
}

################################################################################
# Reset-Office365Users
################################################################################
function Reset-Office365Users($maxUser, $defaultPassword)
{
    $users = Get-Office365Users
    if ($false -ne $users)
    {
        foreach ($user in $users)
        {
            if ($user.UserPrincipalName -like 'test*')
            {
                if ($false -eq $(Remove-Office365User -user $user))
                {
                    return $false
                }
            }
        }
    }
    return New-Office365Users -max $maxUser -defaultPassword $defaultPassword
}

############################################################
# Test-IsTenantDehydrated
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
# Test-UserHasImpersonationRights
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
# Enable-TenantCustomization
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
# Add-ImpersonationRights
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

################################################################################
# Enable Impersonation
################################################################################
function Confirm-ImpersonationRights($username)
{
    # Test if tenant is dehydrated
    $isDehydrated = Test-IsTenantDehydrated

    # Fail if we cannot get this information
    if ($null -eq $isDehydrated)
    {
        return $false
    }
    
    # Enable-OrganizationCustomization if tenant is dehydrated
    if ($true -eq $isDehydrated)
    {
        if ($false -eq $(Enable-TenantCustomization))
        {
            return $false
        }
    }

    # Test if user has Impersonation rights
    $hasRights = Test-HasImpersonationRights -username $username
    if ($false -eq $hasRights)
    {
        # Add Impersonation rights
        return Add-ImpersonationRights -username $username
    }
    return $true
}

################################################################################
# Reset-Office365Tenant
################################################################################
function Reset-Office365Tenant($credentials, $defaultPassword, $maxUser)
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

    # Connect to Office 365
    Write-Host -ForegroundColor Yellow "Connect to Office 365"
    $session = Connect-Office365 -credentials $credentials
    if ($false -eq $session)
    {
        return $false
    }

    # Reset all users
    Write-Host -ForegroundColor Yellow "Reset Office 365 Users"
    $rc = Reset-Office365Users -maxUser $maxUser -defaultPassword $defaultPassword
    if ($false -eq $rc)
    {
        return $false
    }
    
    # Enable impersonation
    Write-Host -ForegroundColor Yellow "Confirm Impersonation for the Admin"
    $rc = Confirm-ImpersonationRights -user $credentials.UserName
    if ($false -eq $rc)
    {
        return $false
    }
    
    return $true
}