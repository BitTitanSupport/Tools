<#
.NOTES
    Company:        BitTitan, Inc.
    Title:          Get-PublicFolderSplitFolders.ps1
    Author:         support@bittitan.com
    
    Version:        1.00
    Date:           May 21, 2018

    Disclaimer:     This script is provided ‘AS IS’. No warranty is provided either expresses or implied.

    Copyright:      Copyright © 2018 BitTitan. All rights reserved.
    
.DESCRIPTION    
    Generates a full report of the decoded filters for a Public Folder Split project.

.INPUTS
    -Credentials Input type [PSCredential]
    -ImpersonateUserId Input type [Guid]
    -ConnectorID Input type [Guid]

.EXAMPLE
    .\Get-PublicFolderSplitFolders.ps1 [-Credentials $credentials] -ImpersonateUserId 12345678-0000-0000-0000-000000000000 -ConnectorID 87654321-0000-0000-0000-000000000000 > filters.txt
#>

param(
    [Parameter(Mandatory=$false)]
    [PSCredential] $Credentials,
    [Parameter(Mandatory=$True)]
    [guid] $ImpersonateUserId,
    [Parameter(Mandatory=$True)]
    [guid] $ConnectorID
) 

# Set strict mode.
Set-StrictMode -Version 2.0

# Disable progress bar.
$ProgressPreference = "SilentlyContinue"

# Set default ErrorAction to Stop.
$ErrorActionPreference = "Stop"

# Import-Module
$scriptPath = $script:MyInvocation.MyCommand.Path
$scriptDirectory = Split-Path $scriptPath
Import-Module "$scriptDirectory\..\BTModules\BTSupport.psm1" -Force -DisableNameChecking
Import-Module "$scriptDirectory\..\BTModules\BTMigrationWiz.psm1" -Force -DisableNameChecking
Import-Module "$scriptDirectory\Get-PublicFolderSplitFolders.psm1" -Force -DisableNameChecking

# Import BitTitan PowerShell Module
if (Import-BitTitanPowerShellModule)
{
    # Ask for credentials if not provided
    if ($null -eq $Credentials)
    {
        $Credentials = Get-UserCredential -message "Enter your MigrationWiz Credentials"
    }

    # If we have credentials
    if ($null -ne $Credentials)
    {
        # Get all the mailboxes for this connector
        $mailboxes = Get-AllMailboxesForConnector -credentials $Credentials -impersonateUserId $ImpersonateUserId -connectorID $ConnectorID

        if ($true -eq $mailboxes)
        {
            foreach ($mailbox in $mailboxes)
            {
                $mailboxID = $mailbox.ID
                $folderFilter = $mailbox.FolderFilter
                $publicFolderPath = $mailbox.PublicFolderPath

                Write-Output "Found MailboxID [$mailboxID] -> $publicFolderPath"
                Write-Output "Mailbox Link [https://migrationwiz.bittitan.com/app/projects/$ConnectorID/$mailboxID/edit]"

                # Get the filter for current line item
                $includeFilter = $folderFilter -replace '^(#includes_encoded=([a-z0-9|=]+))','$2'
                $filters = $includeFilter.Split('|')

                # Loop through all the filters
                foreach ($filter in $filters)
                {
                    try
                    {
                        # Replace the '#' with '+' if any. Hack!
                        $filter = $filter.Replace('#', '+')

                        # Decode the string.
                        $decoded = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($filter))

                        Write-Output " Found Filter [$decoded]"
                    }
                    catch
                    {
                        Write-Host " Error $($PSItem.ToString())."
                    }
                }
            }
        }
    }
}