<#
.NOTES
    Company:          BitTitan, Inc.
    Title:            List-AllCompletedMigrations.ps1
    Email:            Support@BitTitan.com
    Author:           Jason Ege

    Version:          1.00
    Date:             February 13, 2019

    Disclaimer:       This script is provided 'AS IS'. No warranty is provided either expressed or implied

    Copyright:        Copyright © 2019 BitTitan. All rights reserved

.SYNOPSIS
    This script gives you a list of all of your completed migrations.

.DESCRIPTION
    This script looks at all of the migrations across all of the projects in your MigrationWiz account and lists all that
    have completed either a pre-stage pass or a full pass. At the end, it gives you the option to export the list to a text file.

.REQUIREMENTS
    This script can be run by right-clicking on the script and selecting, "Run With Powershell", but still requires the
    BitTitan Powershell to be installed on the machine at "Program Files (x86)\BitTitan\BitTitan Powershell\BitTitanPowerShell.dll"

#>

Import-Module "${env:ProgramFiles(x86)}\BitTitan\BitTitan PowerShell\BitTitanPowerShell.dll"

$creds = Get-Credential -Message "Enter your BitTitan Credentials"
$mwTicket = Get-MW_Ticket -Credentials $creds
$projects = Get-MW_MailboxConnector -Ticket $mwTicket -RetrieveAll

$mailboxesInProject = @()

for ($i = 0; $i -lt $projects.Length; $i++)
{
    $mailboxesInProject += Get-MW_MailboxMigration -Ticket $mwTicket -ConnectorId $projects[$i].Id -Status "Completed" -Type Full
}

$mailboxesInProject

Write-Host "Export this list to a file? (y/n)"
$askExport = Read-Host

if ($askExport -eq "y" -or $askExport -eq "Y")
{
    $nowTime = Get-Date -Format yyyy_MM_dd_tz_THH_mm_ss
    $outFilePath = "$env:USERPROFILE\Desktop\CompleteMigrations $nowTime.txt"
    $mailboxesInProject | Out-File -FilePath $outFilePath -Force
    
    Write-Host "File created at: $outFilePath"
}
else
{
    Write-Host "A file containing this information was not exported."
}

Write-Host "`nPress ENTER to exit"

Read-Host