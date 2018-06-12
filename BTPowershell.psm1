# Set strict mode.
Set-StrictMode -Version 2.0

# Disable progress bar.
$ProgressPreference = "SilentlyContinue"

# Set default ErrorAction to Stop.
$ErrorActionPreference = "Stop"

################################################################################
# Get all customer end users based on the name of the customer
################################################################################
function Get-EndUsers($ticket, $customerCompanyName)
{
    try
    {
        DisplayInProgressOperation "Get end users"

        # Get the list of end users.
        $endUsers = Get-BT_CustomerEndUser -Ticket $ticket -CustomerCompanyName $customerCompanyName -RetrieveAll

        DisplayCompletedOperation "OK" Green
        return $endUsers
    }
    catch
    {
        DisplayCompletedOperation "FAIL" Red
        Write-Host -ForegroundColor Red "FATAL: Export-CustomerEndUserListToCsv failed with $_"
        return $false
    }
}

################################################################################
# Export List of Customer End Users to CSV
################################################################################
function Export-CustomerEndUsersToCsv($endUsers, $csvPath = "${env:USERPROFILE}\Desktop\CustomerCSV.csv")
{
    try
    {
        DisplayInProgressOperation "Export end users to csv"

        # Export the list of end users to a CSV (default location is the desktop).
        $endUsers | Export-Csv -Path $csvPath

        DisplayCompletedOperation "OK" Green
        return $true
    }
    catch
    {
        DisplayCompletedOperation "FAIL" Red
        Write-Host -ForegroundColor Red "FATAL: Export-CustomerEndUserListToCsv failed with $_"
        Write-Host -ForegroundColor Red "Could not export to CSV. Is the CSV already open in another program?"
        return $false
    }
}