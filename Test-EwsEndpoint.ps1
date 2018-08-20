<#
.NOTES
    Company:          BitTitan, Inc.
    Title:            Test-EwsEndpoint.ps1
    Author:           Support@BitTitan.com

    Version:          1.00
    Date:             August 3, 2018

    Disclaimer:       This script is provided 'AS IS'. No warranty is provided either expressed or implied

    Copyright:        Copyright © 2018 BitTitan. All rights reserved

.SYNOPSIS
    Tests connectivity of EWS endpoints

.DESCRIPTION
    This script tests the connectivity of an EWS endpoint(s) configured in MigrationWiz project 
    connector(s). Using the unique project information an EWS endpoint URL is generated based on the 
    OWA URL of a connector. The EWS endpoint URL is then used to confirm the EWS endpoint exists, and 
    can be connected to using the information in the project.

#>


Import-Module BTMigrationWiz.psm1
Import-Module BTSupport.psm1
Import-BitTitanPowerShellModule


# Test EWS URL configured in a connector
function EWSUrlTest
{

    Param
    (
        [Parameter(Mandatory=$true)]
        $EWS_URL,
        $credentials
    )

    # Check $EWS_URL and transform to correct syntax if necessary
    if(($EWS_url.ToCharArray() | ?{$_ -eq '/'}).count -ge 3)
    {
        $EWS_url = $EWS_url.split('/')[2] ; $EWS_url = 'https://' + $EWS_url + '/ews/services.wsdl'
    }
    elseif($EWS_url.StartsWith('http://') -or $EWS_url.StartsWith('https://'))
    {
        $EWS_url = $EWS_url.split('/')[2] ; $EWS_url = 'https://' + $EWS_url + '/ews/services.wsdl'
    }
    else
    {
        $EWS_url = 'https://' + $EWS_url + '/ews/services.wsdl'
    }

    # Test connectivity to EWS endpoint
    try
    {
        if((Invoke-WebRequest -Uri $EWS_url -Credential $credentials).StatusCode -eq 200)
        {
            Write-Host -ForegroundColor Green "EWS connection to endpoint $EWS_url was successful"
        }
    }
    catch
    {
        Write-Host -ForegroundColor Red "Error. EWS check failed with $_"
    }

}



function Test-EwsEndpoints
{

    Param
    (
        [Parameter(Mandatory=$true)]
        [string]$projectID
    )

    # Remove variable $BTUserCredential if it exists.
    if($BTUserCredential)
    {
        Remove-Variable BTUserCredential
    }

    # Ask for credentials.
    try
    {
        $BTUserCredential = Get-Credential -Message "Enter you BitTitan credentials"
    }
    catch
    {
        Write-Host -ForegroundColor Red  "Error. Get credentials failed with $_"
        Return;
    }

    # Request ticket with elevated privilage.
    try
    {
        $ticket = Get-MW_Ticket -Credentials $BTUserCredential -ElevatePrivilege:$true
    }
    catch
    {
        Write-Host -ForegroundColor Red  "Error. Getting MigationWiz ticket failed with $_"
        Return;
    }

    # Get mailbox connector based on $projectID provided.
    try
    {
        $mailboxConnector = Get-MW_MailboxConnector -Ticket $ticket -Id $projectID -ShouldUnmaskProperties:$true
    }
    catch
    {
        Write-Host -ForegroundColor Red  "Error. Getting mailbox connector failed with $_"
        Return;
    }

    # Check if ProjectType is Mailbox or Archive
    if($($mailboxconnector.ProjectType) -ne "Mailbox" -and $($mailboxconnector.ProjectType) -ne "Archive ")
    {
        Write-Host "$($mailboxConnector.Name) is a $($mailboxConnector.ProjectType) project, not a Mailbox project."
        Return;
    }

    # Gather Export credentials
    $secureExportPassword = $($mailboxConnector.ExportAdministrativePassword) | ConvertTo-SecureString -AsPlainText -Force
    $secureExportCreds = New-Object System.Management.Automation.PSCredential -ArgumentList $($mailboxConnector.ExportAdministrativeUserName), $secureExportPassword

    # Determine whether Office 365 or customer EWS URL will be used to test connectivity against
    if($mailboxConnector.ExportType -eq "ExchangeOnline2")
    {
        $exportUrl = 'https://outlook.office365.com/EWS/Exchange.asmx'
    }
    else
    {
        $exportUrl = $mailboxConnector.ExportConfiguration.Url
    }

    # Gather Import credentials
    $secureImportPassword = $($mailboxConnector.ImportAdministrativePassword) | ConvertTo-SecureString -AsPlainText -Force
    $secureImportCreds = New-Object System.Management.Automation.PSCredential -ArgumentList $($mailboxConnector.ImportAdministrativeUserName), $secureImportPassword

    # Determine whether Office 365 or custom EWS URL will be used to test connectivity against
    if($mailboxConnector.ImportType -eq "ExchangeOnline2")
    {
        $importUrl = 'https://outlook.office365.com/EWS/Exchange.asmx'
    }
    else
    {
        $importUrl = $mailboxConnector.ImportConfiguration.Url
    }

    # Run EWS URL connectivity check
    Write-Host "Export EWS URL Test against $exportUrl"
    EWSUrlTest -EWS_URL $exportUrl -Credentials $secureExportCreds
    Write-Host "Import EWS URL Test against $importUrl`n`n"
    EWSUrlTest -EWS_Url $importUrl -Credentials $secureImportCreds

}

Test-EwsEndpoints


