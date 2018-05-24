# Set strict mode.
Set-StrictMode -Version 2.0

# Disable progress bar.
$ProgressPreference ="SilentlyContinue"

# Set default ErrorAction to Stop.
$ErrorActionPreference = "Stop"

# Get the auth cookie for a site using the CS code. 
function Get-DevConsoleCookies($url)
{
    $null = [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $null = [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

    Add-Type -Path ".\GetCookies.cs" -ReferencedAssemblies @("System.Windows.Forms","System.Drawing") -ErrorAction SilentlyContinue

    if ([GetCookies.Program]::cookies -eq $null)
    {
        [GetCookies.Program]::Main($url)
    }

    $cookies = [GetCookies.Program]::cookies;
    return $cookies
}

# Get the name of the lastest DevConsole.
function Get-LastestDevConsoleFilename($URL, $cookies)
{
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    foreach ($cookie in $cookies.getCookies($URL))
    {
        $session.Cookies.Add($cookie);
    }

    # Force TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $page = Invoke-WebRequest $URL -WebSession $session

    if ($page -match "<A HREF=""/(BitTitan.DevConsole.*?)""")
    {
        return $Matches[1]
    }
}

# Download the lastest DevConsole.
function Download-DevConsole($URL, $cookies, $filename, $outfile)
{
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    foreach ($cookie in $cookies.getCookies($URL))
    {
        $session.Cookies.Add($cookie);
    }

    # Force TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest "$URL/$filename" -WebSession $session -OutFile $outfile | Out-Null
}