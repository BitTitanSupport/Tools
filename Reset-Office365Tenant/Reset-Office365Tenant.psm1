# Set strict mode.
Set-StrictMode -Version 2.0

# Disable progress bar.
$ProgressPreference = "SilentlyContinue"

# Set default ErrorAction to Stop.
$ErrorActionPreference = "Stop"

############################################################
# Add test users to Office 365
############################################################
function Add-Office365Users($max, $defaultPassword)
{
    # Get available SKUs.
    $skus = Get-AvailableAccountSku

    # If no SKUs are available
    if ($false -eq $skus)
    {
        return $false
    }
    else
    {
        # Cap the max number of users created to the number of available SKU
        $availableSkus = $($skus[0].ActiveUnits - $skus[0].ConsumedUnits)
        if ($max -gt $availableSkus)
        {
            Write-Host -ForegroundColor Yellow "WARNING: Only $($skus[0].ActiveUnits - $skus[0].ConsumedUnits) SKUs for $max."
            $max = $availableSkus
        }
    }

    # Gets the Primary SMTPAddressTemplate to build the user email address
    try
    {
        $primarySMTPAddressTemplate = Get-EnabledPrimarySMTPAddressTemplate
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
        $email     = "test{0:D3}{1}" -F $number, $primarySMTPAddressTemplate
        $sku       = $skus[0].AccountSkuId

        if ($false -eq $(New-Office365User -email $email -firstName $firstName -lastName $lastName -usageLocation "US" -sku $sku -defaultPassword $defaultPassword))
        {
            return $false
        }
    }
    return $true
}

################################################################################
# Reset all Office365 Users
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
    return Add-Office365Users -max $maxUser -defaultPassword $defaultPassword
}

################################################################################
# Confirms if user has Impersonation Rights
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
# Reset Office365 Tenant
################################################################################


<#
.SYNOPSIS
#

.DESCRIPTION
Long description

.PARAMETER credentials
Parameter description

.PARAMETER defaultPassword
Parameter description

.PARAMETER maxUser
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Reset-Office365Tenant($credentials, $defaultPassword, $maxUser)
{
    if ($null -eq $credentials)
    {
        Write-Host "Ask for credentials"
        $credentials = Get-UserCredential -Message "Enter your Office365 Admin Credentials" 
        if ($null -eq $credentials)
        {
            return $false
        }
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