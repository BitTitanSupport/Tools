
<#
.NOTES
    Company:          BitTitan, Inc.
    Title:            Export-CustomerEndUserListToCSVBasedOnCompanyName.ps1
    Author:           Support@BitTitan.com

    Version:          1.00
    Date:             September 4, 2018

    Disclaimer:       This script is provided 'AS IS'. No warranty is provided either expressed or implied

    Copyright:        Copyright © 2018 BitTitan. All rights reserved

.SYNOPSIS
    Exports a list of end users from a specific customer.

.DESCRIPTION
    This script will take in a customer and will output a list of all the end users within that customer to a CSV file.

#>

# Get the user's BitTitan credentials.
$creds = Get-Credential -Message "Enter your BitTitan credentials"

try
{
    # Create a ticket.
    $ticket = Get-BT_Ticket -Credentials $creds
}
catch
{
    Write-Host "Error retrieving the ticket. Check credentials and try again."
}

# Get the domain name of the customer by which to filter.
Write-Host "What is the customer's name, as entered in MSPComplete?"
$customerCompanyName = Read-Host

try
{
    # Get the list of end users.
    $endUsers = Get-BT_CustomerEndUser -Ticket $ticket -CustomerCompanyName $customerCompanyName -RetrieveAll
}
catch
{
    Write-Host "Error retrieving the customer end users."
}

try
{
    # Export the list of end users to a CSV on the desktop.
    $endUsers | Export-Csv -Path "${env:USERPROFILE}\Desktop\$customerCompanyName EndUsers.csv" -NoTypeInformation
    Write-Host "CSV `"$customerCompanyName EndUsers.csv`" successfully exported to the Desktop"
}
catch
{
    Write-Host "Could not export to CSV. Is it open in another program?"
}