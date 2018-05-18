# SYNOPSIS
Resets an Office 365 Tenant.

### DESCRIPTION
This script will reset an Office 365 tenant to be used by BitTitan Support team.

### PARAMETER credentials
The credentials to Connect to Office 365. This parameter is optional.

### PARAMETER defaultPassword
The default password for all the users created in Office 365.

### PARAMETER maxUser
The maximum number of user to create.

### EXAMPLE

    $credentials = Get-Credential
    Reset-Office365Tenant.ps1 -maxUser 10 -defaultPassword "OinkOink" [-credentials $credentials]

### NOTES
General notes

This script will:

* Delete all users named test*
* Create the specified number of users in Office 365.
* Enable Application Impersonation for the admin.