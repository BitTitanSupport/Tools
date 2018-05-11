# Set strict mode.
Set-StrictMode -Version 2.0

# Disable progress bar.
$ProgressPreference ="SilentlyContinue"

# Set default ErrorAction to Stop.
$ErrorActionPreference = "Stop"

#Import-Module
Import-Module ".\GetDevConsole.psm1" -Force -DisableNameChecking

# URL of the console tool.
$URL = "https://btdevconsole.azurewebsites.net"

# Get the authentication cookie.
$cookies = Get-DevConsoleCookies $URL

# Get the name of the lastest DevConsole file.
$filename = Get-LastestDevConsoleFilename $URL $cookies

# Download the lastest DevConsole file.
Download-DevConsole $URL $cookies $filename  $filename 