<#
.NOTES
    Company:          BitTitan, Inc.
    Title:            ShardMailboxBulkCheck.ps1
    Author:           Support@BitTitan.com

    Version:          1.00
    Date:             November 20, 2018

    Disclaimer:       This script is provided 'AS IS'. No warranty is provided either expressed or implied

    Copyright:        Copyright © 2018 BitTitan. All rights reserved

.SYNOPSIS
    This script tells you, in bulk, if Office 365 users have a shard mailbox.

.DESCRIPTION
    This script takes in a CSV containing a list of Office 365 end users' email address, and outputs whether it is a shard mailbox or not.

#>

# Connect to Office 365 using credentials
$userCredential = Get-Credential -Message "Enter your Office 365 Admin Credentials"
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $userCredential -Authentication Basic -AllowRedirection
Import-PSSession $session -DisableNameChecking

try
{
    # Gather information about the end user
    Write-Host "Enter the file path and name of the CSV containing the users to test:"
    $inputUserList = Read-Host
    $endUserListCsv = Import-Csv -Path $inputUserList
    $endUserList = ConvertFrom-Csv $endUserListCsv -Header User
    
    for ($i = 0; $i -lt $endUserList.Count; $i++)
    {
        $endUserToTest = $endUserList[$i]
        #$endUserToTest = $endUserToTest.Replace("@{User=@{User=","")
        $endUserToTest = $endUserToTest -replace '@{User=@{User=', ''
        $endUserToTest = $endUserToTest.Replace("}}","")
        $locations = (Get-MailboxLocation -User $endUserToTest)

        # Determine if the mailbox is a "shard" mailbox or not and report back accordingly.
        if ($locations.MailboxLocationType -like "*ComponentShared*")
        {
            Write-Host $endUserToTest "IS a shard mailbox" -ForegroundColor Yellow
        }
        else
        {
            Write-Host $endUserToTest "is NOT a shard mailbox" -ForegroundColor Green
        }
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
Write-Host "`nPress ENTER to exit."
Read-Host