# Set strict mode.
Set-StrictMode -Version 2.0

# Disable progress bar.
$ProgressPreference = "SilentlyContinue"

# Set default ErrorAction to Stop.
$ErrorActionPreference = "Stop"

################################################################################
# Get a MigrationWiz Ticket.
################################################################################
function Get-MigrationWizTicket($credentials)
{
    try
    {
        DisplayInProgressOperation "Get MigrationWiz Ticket"
        $MWTicket = Get-MW_Ticket -Credentials $credentials -KeepPrivileged
        DisplayCompletedOperation "OK" Green
        return $MWTicket
    }
    catch
    {
        DisplayCompletedOperation "FAIL" Red
        Write-Host -ForegroundColor Red "FATAL: Get-MW_Ticket failed with $_"
        return $false
    }
}

################################################################################
# Get a MigrationWiz Impersonated Ticket.
################################################################################
function Get-MigrationWizImpersonatedTicket($ticket, $credentials, $impersonateUserId)
{
    try
    {
        DisplayInProgressOperation "Get MigrationWiz Impersonated Ticket"
        $MWUserTicket = Get-MW_Ticket -Credentials $credentials -Ticket $ticket -ImpersonateId $impersonateUserId
        DisplayCompletedOperation "OK" Green
        return $MWUserTicket
    }
    catch
    {
        DisplayCompletedOperation "FAIL" Red
        Write-Host -ForegroundColor Red "FATAL: Get-MW_Ticket failed with $_"
        Write-Host -ForegroundColor Red "FATAL: Probably user not found..."
        return $false
    }
}

################################################################################
# Get a MigrationWiz Connector.
################################################################################
function Get-MigrationWizConnector($ticket, $connectorId)
{
    try
    {
        DisplayInProgressOperation "Get MigrationWiz Connector"
        $connector = Get-MW_MailboxConnector -Ticket $ticket -FilterBy_Guid_Id $connectorID
        DisplayCompletedOperation "OK" Green
        return $connector
    }
    catch
    {
        DisplayCompletedOperation "FAIL" Red
        Write-Host -ForegroundColor Red "FATAL: Get-MW_MailboxConnector failed with $_"
        return $false
    }
}

################################################################################
# Get a MigrationWiz Connector.
################################################################################
function Get-MigrationWizMailboxes($ticket, $connectorId)
{
    try
    {
        DisplayInProgressOperation "Get MigrationWiz Mailboxes"
        $mailboxes = Get-MW_Mailbox -Ticket $ticket -ConnectorId $connectorId
        DisplayCompletedOperation "OK" Green
        return $mailboxes
    }
    catch
    {
        DisplayCompletedOperation "FAIL" Red
        Write-Host -ForegroundColor Red "FATAL: Get-MW_Mailbox failed with $_"
        return $false
    }
}

################################################################################
# Get User Credentials
################################################################################
function Get-UserCredential($message = "Enter your Credentials")
{
    try
    {
        DisplayInProgressOperation $message
        $credentials = Get-Credential
        DisplayCompletedOperation "OK" Green
        return $credentials
    }
    catch
    {
        DisplayCompletedOperation "FAIL" Red
        Write-Host -ForegroundColor Red "ERROR: Get-Credential failed with $_"
        return $null
    }
}