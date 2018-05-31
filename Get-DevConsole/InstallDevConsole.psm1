# Progress indicator
$ProgressPreference = "SilentlyContinue"

# Set strict mode.
Set-StrictMode -Version 2.0
 
# Set default ErrorAction to Stop.
$ErrorActionPreference = "Stop"


################################################################################
# Display messages on screen
################################################################################
Function Write-Message ($color, $message)
{
    Write-Host -ForegroundColor $color -Object $message -NoNewline
}

################################################################################
# Retreieve Office365 authentication cookie
################################################################################
Function Get-Cookies ($URL)
{
    try 
    {
        DisplayInProgressOperation -text "Generating authentication cookie"
        $cookies = Get-DevConsoleCookies $URL
        DisplayCompletedOperation -color Green -text "OK"   
    }
    catch
    {
        DisplayCompletedOperation -color Red -text "Fail"
        Write-Message -color Red -message "Failed to get authentication cookie"
        Write-Message -color Red -message "Error: $_"
        return $false
    }
    
    return $cookies
}

################################################################################
# Scrapes DevConsole full build name from the download site
################################################################################
Function Get-DevConsoleBuildFullFileName ($URL, $cookies)
{
    try
    {
        DisplayInProgressOperation -text "Gathering build information"
        $devConsoleBuildFullFileName = Get-LastestDevConsoleFilename $URL $cookies
        DisplayCompletedOperation -color Green -text "OK"
    }
    catch
    {
        DisplayCompletedOperation -color Red -text "Fail"
        Write-Message -color Red -message "Failed to get latest DevConsole filename"
        Write-Message -color Red -message "Error: $_"
        return $false
    }

    return $devConsoleBuildFullFileName
}

################################################################################
# Converts full build name to a short name
################################################################################
Function Get-DevConsoleBuildShortFileName ($devConsoleBuildFullFileName)
{
    try
    {
        $regularExpression = "((BitTitan\.DevConsole\.)(\d{1}\.\d{1}\.\d{5}\.\d{5})(-master\.zip))"
        $devConsoleBuildShortFileName = $devConsoleBuildFullFileName -replace $regularExpression,'$3'
    }
    catch
    {
        Write-Message -color Red -message "Unable to parse DevConsole full file name"
        Write-Message -color Red -message "Error: $_"
        return $false
    }

    return $devConsoleBuildShortFileName
}

################################################################################
# Determine if a previous version of the DevConsole is on the local machine
################################################################################
Function Get-IsFirstSetup ($currentInstallationDirectory)
{
    try
    {
        $locateCurrentBuild =  Get-Item "$currentInstallationDirectory\DevConsole.exe" | Select-Object -ExpandProperty VersionInfo
        #DisplayCompletedOperation -color Green -text "OK"       
    }
    catch [System.Management.Automation.ItemNotFoundException]
    {
        $locateCurrentBuild = $null
        DisplayCompletedOperation -color Green -text "New install required"
    }

    return $locateCurrentBuild
}

################################################################################
# Determine if the DevConsole needs to be updated
################################################################################
Function Test-IfUpdateIsNeeded ()
{
    DisplayInProgressOperation -text "Searching for previous version"
    $latestBuild = Get-DevConsoleBuildShortFileName -devConsoleBuildFullFileName $devConsoleBuildFullFileName
    $currentBuild = Get-IsFirstSetup -currentInstallationDirectory $currentInstallationDirectory

    try
    {
        if ($latestBuild -eq $currentBuild.FileVersion)
        {
            DisplayCompletedOperation -color Green -text "Update not needed"
            break
        }
        else 
        {
            DisplayCompletedOperation -color Green -text "Update needed"
            $IsFirstSetup = $false
        }
    }
    catch
    {
        $IsFirstSetup = $true
    }   
    return $IsFirstSetup    
}

################################################################################
# Create folder structure to store DevConsole data
################################################################################
Function Add-FolderStructure ($directoryName)
{
    try 
    {
        if (-not (Test-Path -Path $directoryName))
        {
            New-Item -ItemType Directory -Path $directoryName > $null
        }  
    }
    catch 
    {
        Write-Message -color Red -message "Failed to create DevConsole folder structure"
        Write-Message -color Red -message "Error: $_"
    }
       
}

################################################################################
# Terminate DevConsole process
################################################################################
Function Stop-DevConsole()
{
    try
    {    
        Get-process | Where-Object {$_.ProcessName -eq 'DevConsole'} | Stop-Process -Force
    }
    catch
    {
        Write-Message -color Red -message "Failed to stop active DevConsole session"
        Write-Message -color Red -message "Error: $_"
        return $false  
    }
}

################################################################################
# Install latest version of the DevConsole
################################################################################
Function Start-InstallDevConsole ($devConsoleBuildFullFileName, $currentInstallationDirectory, $temporaryDownloadDirectory)
{
    try
    {
        Stop-DevConsole
        Expand-Archive -Path $("$temporaryDownloadDirectory\$devConsoleBuildFullFileName") -DestinationPath "$currentInstallationDirectory" -Force
    }
    catch
    {
        Write-Message -color Red -message "Failed to install the DevConsole"
        Write-Message -color Red -message "Error: $_"
        retrun $false  
    }

    return $true
}

################################################################################
# Move current installation directory to old cache directory
################################################################################
Function Move-CurrentBuildDirectory($isFirstSetup)
{
    try
    {
        #Move current build to old cache
        if ($false -eq $isFirstSetup)
        {
            $Date = (Get-Date -Format d).Replace("/","-")
            $currentCache = Get-ChildItem -Path "$currentInstallationDirectory"

            if (-not (Test-Path "$oldCacheDirectory\$Date"))
            {
                New-Item -Path "$oldCacheDirectory\$Date" -Type "Directory" > $null
            }

            foreach ($items in $currentCache)
            {
                Move-Item -Path $items.FullName -Destination $("$oldCacheDirectory\$Date") -Force
            }
        }
    }   
    catch
    {
        Write-Message -color Red -message "Unable to move files from $currentInstallationDirectory"
        Write-Message -color Red -message "Error: $_"
    }
    
}

################################################################################
# Clean up items older than 1 month from old cache directory
################################################################################
Function Clear-OldDirectory ($isFirstSetup)
{
    if($false -eq $isFirstSetup)
    {
        try
        {
            $oldCacheItems =  Get-ChildItem -Path "$oldCacheDirectory"
    
            foreach ($items in $oldCacheItems)
            {
                if ($items.LastWriteTime -lt (Get-Date).AddMonths(-1))
                {
                    Remove-Item -Path $items.FullName -Recurse -Force
                }
            }
        }
        catch
        {
            Write-Message -color Red -message "Unable to delete items older than 1 month from the directory $oldCacheDirectory"
            Write-Message -color Red -message "Error: $_"
        }
    }
  
}

################################################################################
# Clear temporary download directory after installation completes
################################################################################
Function Clear-TemporaryDownloadDirectoryectory ($isInstallationComplete)
{
    try 
    {
        $tempCache =  Get-ChildItem -Path "$temporaryDownloadDirectory"
        if ($isInstallationComplete -eq $True)
        {
            foreach ($items in $tempCache)
            {
                Remove-Item -Path $items.FullName -Force
            }
        } 
    }
    catch 
    {
        Write-Message -color Red -message "Unable to delete the ZIP file from the directory $temporaryDownloadDirectory"
        Write-Message -color Red -message "Error: $_"
    }
}

################################################################################
# Updates the DevConsole on the local machine
################################################################################
Function Install-DevConsole
{
    # URL of the console tool.
    $URL = "https://btdevconsole.azurewebsites.net"


    # Install Directories
    $devConsoleDirectory = "$env:USERPROFILE\Documents\Migration Service"
    $oldCacheDirectory = "$devConsoleDirectory\Old"
    $currentInstallationDirectory = "$devConsoleDirectory\Current"
    $temporaryDownloadDirectory = "$devConsoleDirectory\Temp"

    
    # Start main process

    # Main data gathering
    $cookies = Get-Cookies -URL $URL

    if($false -ne $cookies)
    {
        $devConsoleBuildFullFileName = Get-DevConsoleBuildFullFileName -URL $URL -cookies $cookies
    }
    
    if($false -ne $devConsoleBuildFullFileName)
    {
        $isFirstSetup = Test-IfUpdateIsNeeded 
    }
    
    # Create structure if it doesn't exist
    if ($true -eq $isFirstSetup)
    {
        try
        {
            Add-FolderStructure -directoryName $oldCacheDirectory
            Add-FolderStructure -directoryName $currentInstallationDirectory
            Add-FolderStructure -directoryName $temporaryDownloadDirectory

            $folderCreationSuccessful = $true
        }
        catch
        {
            $folderCreationSuccessful = $false
        }
    }
    else
    {
        $folderCreationSuccessful = $true
    }

    # Clean up previous installation files and directories
    if(($false -ne $folderCreationSuccessful) -or ($false -eq $isFirstSetup))
    {
        try
        {
            Move-CurrentBuildDirectory -isFirstSetup $isFirstSetup
            Clear-OldDirectory -isFirstSetup $isFirstSetup
            $cleanUpOfDataSuccessful = $true
        }
        catch
        {
            $cleanUpOfDataSuccessful = $false
        }
    }
    else
    {
        $cleanUpOfDataSuccessful = $null
    }

    # Download and install the latest build
    if($false -ne $cleanUpOfDataSuccessful)
    {
        DisplayInProgressOperation -text "Starting Download"
        try
        {
            Download-DevConsole -URL $URL -cookies $cookies -filename $devConsoleBuildFullFileName -outfile $("$temporaryDownloadDirectory\$DevConsoleBuildFullFileName")
            DisplayCompletedOperation -color Green -text "OK"
            $isDownloadComplete = $true
        }
        catch
        {
            $isDownloadComplete = $false
            DisplayCompletedOperation -color Green -text "Failed"
        }
    }

    if($false -ne $isDownloadComplete)
    {
        DisplayInProgressOperation -text "Starting Install"
        $isInstallationComplete = Start-InstallDevConsole -currentInstallationDirectory $currentInstallationDirectory -devConsoleBuildFullFileName $devConsoleBuildFullFileName -temporaryDownloadDirectory $temporaryDownloadDirectory
        
        # Clear temp directory
        if($false -ne $isInstallationComplete)
        {
            Clear-TemporaryDownloadDirectoryectory -isInstallationComplete $isInstallationComplete
            DisplayCompletedOperation -color Green -text "OK"
            $setupSuccessful = $true
        }
        else
        {
            $setupSuccessful = $false
            DisplayCompletedOperation -color Green -text "Failed"
        }
    }
    
    return $setupSuccessful
}
