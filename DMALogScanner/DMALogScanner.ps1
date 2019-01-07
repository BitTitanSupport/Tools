<#
.NOTES
    Company:          BitTitan, Inc.
    Title:            DMALogScanner.ps1
    Author:           Jason Ege
    Department:       Support@BitTitan.com

    Version:          1.00
    Date:             January 7, 2019

    Disclaimer:       This script is provided 'AS IS'. No warranty is provided either expressed or implied

    Copyright:        Copyright © 2018 BitTitan. All rights reserved

.SYNOPSIS
    This script parses DMA logs and identifies problems.

.DESCRIPTION
    This script scans multiple DMA log files and outputs errors as well as potential solutions.
#>

# FUTURE IMPROVEMENTS (Ideas that may be implemented in later releases):
# - Detect surrounding context for each error and find a way to include it somewhere, and in a way that does not look cluttered.
# - Add special color coding for special errors
# - Provide additional meaning or potential causes and solutions when certain errors are detected
# - Export two separate log files:
#    - Export a "basic" log file with one occurence of each error (stating the number of occurences).
#    - Export a "verbose" log file with each occurence as a separate complete line, followed by the file name and line number of each entry.

# Asks the user to input the parent folder containing the log files and outputs it as a string if it exists
function Get-LogFileLocation()
{
    do
    {
        # Ask for a log location
        Write-Host "Please provide the path to the parent folder containing the log files (Subfolders will automatically be parsed, as well):"
        $logFileLocation = Read-Host

        # A default log location is used if the user just hits, "ENTER".
        if ($logFileLocation -eq "")
        {
            $logFileLocation = $env:USERPROFILE+"\Desktop\DMALogsToCheck\"
            Write-Host "Using default log location: " $logFileLocation
        }

        # Check if the location provided is a zip file. If so, extract it.
        try
        {
            if ((Test-IfZipFolder $logFileLocation) -eq $true)
            {
                Write-Host "Unpacking zip file."
                $oldLogFileLocation = $logFileLocation
                $logFileLocation = $logFileLocation+" New"
                Expand-Archive $oldLogFileLocation -DestinationPath $logFileLocation
            }
        }
        catch
        {
        }

        # Test the log path to be sure it exists.
        if ((Test-Path $logFileLocation) -eq $true)
        {
            Write-Host "Confirmed the path exists."
            return $logFileLocation
        }
        # If the specified location does not exist, provide an error, loop, and ask again.
        else
        {
            Write-Host "Path does not exist or is inaccessible."
        }
    } while ($true)
}

# This function tests a folder to see if it is a zip archive.
function Test-IfZipFolder($logFileLocationSpecified)
{
    try
    {
        $logFileLocationDetails = Get-Item $logFileLocationSpecified -ErrorAction SilentlyContinue
    }
    catch
    {
        return $false
    }
    if ($logFileLocationDetails -is [System.IO.FileInfo])
    {
        if ($logFileLocationDetails.Extension -eq ".zip")
        {
            return $true
        }
        else
        {
            return $false
        }
    }
    elseif ($logFileLocationDetails -is [System.IO.DirectoryInfo])
    {
        return $false
    }
    else
    {
        retrun $false
    }
}

# This function is a code demonstration and can be removed in later versions.
function Get-NumberOfLinesInFile($logFile)
{
    $lineCount = 0
    $stream = New-Object -TypeName System.IO.FileStream($logFile, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
    if ($stream)
    {
        $reader = New-Object System.IO.StreamReader $stream
        if ($reader)
        {
            while (-not ($reader.EndOfStream))
            {
                [void]$reader.ReadLine()
                $lineCount++
            }
            $reader.Close()
        }
        $stream.Close()
    }
    return $lineCount
}

# Parses the log files line by line and prints the information to the screen.
function Read-LogData($errorsToFind, $inputFile)
{
    [string]$errorsFound = @()
    $lineCount = 0
    $stream = New-Object -TypeName System.IO.FileStream($inputFile, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
    if ($stream)
    {
        $reader = New-Object System.IO.StreamReader($stream)
        if ($reader)
        {
            while (-not ($reader.EndOfStream))
            {
                $lineString = $reader.ReadLine()
                for ($i = 0; $i -lt $errorsToFind.Length; $i++)
                {
                    if ($lineString -like "*$($errorsToFind[$i])*")
                    {
                        $fullLineString = "Result found:`n - Message: $lineString `n - File Name: $inputFile `n - Line Number: $lineCount"

                        # If it is a warning, the line should be displayed in yellow.
                        if ($fullLineString -like "*|WARN|*")
                        {
                            Write-Host $fullLineString -ForegroundColor Yellow
                        }
                        # If it is a warning, the line should be displayed in magenta.
                        elseif ($fullLineString -like "*|ERROR|*")
                        {
                            Write-Host $fullLineString -ForegroundColor Magenta
                        }
                        # If it is anything other than a warning or an error, the line should be displayed in white.
                        else
                        {
                            Write-Host $fullLineString -ForegroundColor White
                        }
                        $errorsFound += $fullLineString+"`n"
                    }
                }
                $lineCount++
            }
            $reader.Close()
        }
        $stream.Close()
    }
    return $errorsFound
}

# Gets the path to the file containing the errors.
function Get-ErrorListLocation()
{
    do
    {
        Write-Host "Provide the path to the file containing the errors to search for:"
        $errorFile = Read-Host
        if ($errorFile -eq "")
        {
            if (Test-Path "DMA Error List.txt")
            {
                $errorList = Get-Content -Path "$env:UserProfile\Desktop\DMA Error List.txt"
                [array]$errorSubset = $errorList.Split("`n")
                return $errorSubset
            }
        }
        else
        {
            if (Test-Path $errorFile)
            {
                $errorList = Get-Content -Path $errorFile
                [array]$errorSubset = $errorList.Split("`n")
                return $errorSubset
            }
            else
            {
                Write-Host "Path does not exist or is inaccessible."
            }
        }
    } while ($true)
}

# Separates out the installation errors, heartbeat errors, and configuration errors.
function Get-ErrorList()
{
    Param(
        [parameter(Mandatory=$true)]
        [ValidateSet("Installation", "Heartbeat", "Configuration")]
        [String[]]$state,
        
        [parameter(Mandatory=$true)]
        [String[]]$errorListLocation
    )

    $errorListState = $state
    foreach ($error in $errorListLocation)
    {
        $errorListState = Get-ErrorState $error $errorListState

        if ($errorListState -eq "Installation")
        {
            if ($error -eq "--Heartbeat--" -or $error -eq "--Configuration--")
            {
                break
            }
            else
            {
                [array]$installErrorList += $error
            }
        }
        elseif ($errorListState -eq "Heartbeat")
        {
            if ($error -eq "--Installation--" -or $error -eq "--Configuration--")
            {
                break
            }
            else
            {
                [array]$heartbeatErrorList += $error
            }
        }
        elseif ($errorListState -eq "Configuration")
        {
            if ($error -eq "--Installation--" -or $error -eq "--Heartbeat--")
            {
                break
            }
            else
            {
                [array]$configurationErrorList += $error
            }
        }
    }
    if ($state -eq "Installation")
    {
        return $installErrorList
    }
    elseif ($state -eq "Heartbeat")
    {
        return $heartbeatErrorList
    }
    elseif ($state -eq "Configuration")
    {
        return $configurationErrorList
    }
}

# Strips the dashes from the error state for ease of use.
function Get-ErrorState($error, $currentState)
{
    if ($error -eq "--Installation--")
    {
        return "Installation"
    }
    elseif ($error -eq "--Heartbeat--")
    {
        return "Heartbeat"
    }
    elseif ($error -eq "--Configuration--")
    {
        return "Configuration"
    }
    else
    {
        return $currentState
    }
}

#Output the results to a file
function Out-ResultsToFile($installErrorsOut, $heartbeatErrorsOut, $configurationErrorsOut)
{
    $outputString = "---INSTALL ERRORS RESULTS---`n"+$installErrorsOut+"`n---HEARTBEAT ERRORS RESULTS---`n"+$heartbeatErrorsOut+"`n---CONFIGURATION ERRORS RESULTS---"+$configurationErrorsOut+"`n`n---END OF FILE---"
    $outputFile = $env:USERPROFILE+"\Desktop\DMA Error Results.txt"
    Write-Host "Outputting results to a log file: " $outputFile
    try
    {
        $outputString | Out-File -FilePath $outputFile
    }
    catch
    {
        Write-Host "Failed to output logs to a file."
        Write-Host $_.Exception.Message
    }
}

# Beginning of main function
function Main()
{

    $logFilesLocation = Get-LogFileLocation

    $allLogFiles = (Get-ChildItem $logFilesLocation -Filter "*.log" -File -Recurse).FullName
    $allLogFiles | fl

    $errorListFile = Get-ErrorListLocation

    $installErrorList = Get-ErrorList -state Installation -errorListLocation $errorListFile
    $heartbeatErrorList = Get-ErrorList -state Heartbeat -errorListLocation $errorListFile
    $configurationErrorList = Get-ErrorList -state Configuration -errorListLocation $errorListFile

    Write-Host "Installation Error List:"
    $installErrorList | fl
    Write-Host "`nHeartbeat Error List:"
    $heartbeatErrorList | fl
    Write-Host "`nConfiguration Error List:"
    $configurationErrorList | fl

    Write-Host "Searching for installation errors"
    foreach ($allLogFile in $allLogFiles)
    {
        $installErrors += Read-LogData $installErrorList $allLogFile
    }

    Write-Host "Searching for heartbeat errors"
    foreach ($allLogFile in $allLogFiles)
    {
        $heartbeatErrors += Read-LogData $heartbeatErrorList $allLogFile
    }

    Write-Host "Searching for configuration errors"
    foreach ($allLogFile in $allLogFiles)
    {
        $configurationErrors += Read-LogData $configurationErrorList $allLogFile
    }

    Out-ResultsToFile $installErrors $heartbeatErrors $configurationErrors

    Write-Host "Log Scanning Process Finished. Press ENTER to close the window."

    Read-Host
}

# Beginning of the script execution.
Main