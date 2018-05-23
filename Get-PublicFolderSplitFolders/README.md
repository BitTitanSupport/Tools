# SYNOPSIS
Generates a full report of the decoded filters for a Public Folder Split project.

### DESCRIPTION
Generates a full report of the decoded filters for a Public Folder Split project.

### PARAMETER credentials
The credentials to Connect to MigrationWiz. This parameter is optional.

### PARAMETER ImpersonateUserId
The MigrationWiz UserID containing the project.

### PARAMETER ConnectorID
The ConnectorID of the project to process.

### EXAMPLE

    $credentials = Get-Credential
    Get-PublicFolderSplitFolders.ps1 [-Credentials $credentials] -ImpersonateUserId 12345678-0000-0000-0000-000000000000 -ConnectorID 87654321-0000-0000-0000-000000000000 > filters.txt

### NOTES

This script will:

* Connect to MigrationWiz.
* Impersonate a user.
* Retrieve all the mailbox under the specified project.
* Display the decoded filter for each line item.