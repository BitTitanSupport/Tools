# Set strict mode.
Set-StrictMode -Version 2.0

# Disable progress bar.
$ProgressPreference = "SilentlyContinue"

# Set default ErrorAction to Stop.
$ErrorActionPreference = "Stop"

################################################################################
# Get the filter for each line items in a Public Folder project.
################################################################################
function Get-AllMailboxesForConnector ($credentials, $impersonateUserId, $connectorID)
{
    # Get a MigrationWiz Ticket
    $mwTicket = Get-MigrationWizTicket $credentials
    if ($false -eq $mwticket)
    {
        return $false
    }

    # Get a MigrationWiz Impersonated Ticket
    $mwUserTicket = Get-MigrationWizImpersonatedTicket -ticket $mwTicket -credentials $credentials -impersonateUserId $impersonateUserId
    if ($false -eq $mwUserTicket)
    {
        return $false
    }

    # Get the connector
    $connector = Get-MigrationWizConnector -ticket $mwUserTicket -connectorId $connectorID
    if ($false -eq $connector)
    {
        return $false
    }

    # Exit if no connector found
    if ($null -eq $connector)
    {
        Write-Host -ForegroundColor Red "No connector found with ID $connectorID."
        return $false
    }

    # Get all the mailboxes for this connector
    $mailboxes = Get-MigrationWizMailboxes -ticket $mwUserTicket -connectorId $connectorID
    if ($false -eq $mailboxes)
    {
        return $false
    }

    return $mailboxes
}