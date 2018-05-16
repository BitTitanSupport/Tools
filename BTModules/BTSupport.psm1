# Set strict mode.
Set-StrictMode -Version 2.0

# Disable progress bar.
$ProgressPreference = "SilentlyContinue"

# Set default ErrorAction to Stop.
$ErrorActionPreference = "Stop"

################################################################################
# Display InProgress Operation
################################################################################
function DisplayInProgressOperation($text)
{
    Write-Host -NoNewLine ("{0,-70} " -f $text)
}

################################################################################
# Display Completed Operation
################################################################################
function DisplayCompletedOperation($text, $color)
{
    Write-Host -ForegroundColor $color "[ $text ]"
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
        Write-Host -ForegroundColor Red "FATAL: Get-MW_Mailbox failed with $_"
        return $null
    }
}
