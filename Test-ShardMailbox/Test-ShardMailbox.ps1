<#
.NOTES
    Company:          BitTitan, Inc.
    Title:            ShardMailboxCheck.ps1
    Author:           Support@BitTitan.com

    Version:          1.00
    Date:             November 16, 2018

    Disclaimer:       This script is provided 'AS IS'. No warranty is provided either expressed or implied

    Copyright:        Copyright © 2018 BitTitan. All rights reserved

.SYNOPSIS
    This script tells you if an Office 365 user has a shard mailbox.

.DESCRIPTION
    This script takes in an Office 365 end user's email address and outputs the mailbox location type (Primary, ComponentShared, etc.) and explicitly states whether it is a shard mailbox or not.

#>

# Connect to Office 365 using credentials
$userCredential = Get-Credential -Message "Enter your Office 365 Admin Credentials"
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $userCredential -Authentication Basic -AllowRedirection
Import-PSSession $session -DisableNameChecking

try
{
    # Gather information about the end user
    Write-Host "Enter the email address of the end user to check"
    $endUserToTest = Read-Host
   
    $locations = (Get-MailboxLocation -User $endUserToTest)
    $locations | Select-Object MailboxLocationType

    # Determine if the mailbox is a "shard" mailbox or not and report back accordingly.
    if ($locations.MailboxLocationType -like "*ComponentShared*")
    {
        Write-Host "Confirmed" $endUserToTest "IS a shard mailbox" -ForegroundColor Yellow
    }
    else
    {
        Write-Host $endUserToTest "is NOT a shard mailbox" -ForegroundColor Green
    }
}
catch
{
    # Report back the error if there is one.
    Write-Host $_.Exception
    Write-Host "An error has occured"
}
finally
{
    # Always remove the Powershell session!
    Remove-PSSession $session
}

# Prompt the user before closing.
Read-Host