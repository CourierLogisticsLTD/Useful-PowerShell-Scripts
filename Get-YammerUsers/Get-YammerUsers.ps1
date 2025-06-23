#Requires -Version 5
<#
.SYNOPSIS
    Query the Yammer API to get a list of (active, suspended, and deleted) Yammer users.

.DESCRIPTION
    Use this script to audit Yammer users.

.PARAMETER N/A

.OUTPUTS Log File
    Log file stored in "Documents\Get-YammerUsers\Get-YammerUsers.log"

.OUTPUTS Transcript File
    Transcript file stored in "Documents\Get-YammerUsers\Get-YammerUsers.transcript"

.OUTPUTS Report File
    Report file stored in "Documents\Get-YammerUsers\Get-YammerUsers.csv"

.NOTES
Version:        1.0
Author:         Louis Lawson

.EXAMPLE
N/A
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

Param ()

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

# Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

# Import Modules & Snap-ins
if (-not (Get-Module PSLogging -ListAvailable)) {
    Install-Module PSLogging -Scope CurrentUser -Force
}
Import-Module PSLogging

#----------------------------------------------------------[Declarations]----------------------------------------------------------

# Script Version
$sScriptVersion = "1.0"
# Get the basename of the script
$sScriptName = (Get-Item $PSCommandPath ).Basename

# Script output directory
$sOutputDir = "$(Join-Path -Path ([Environment]::GetFolderPath("MyDocuments")) -ChildPath $sScriptName)"
# Creates output directory
New-Item -ItemType Directory -Force -Path $sOutputDir -ErrorAction $ErrorActionPreference | Out-Null

# Report file decs
$sReportName = "$sScriptName.csv"
$sReportFile = Join-Path -Path $sOutputDir -ChildPath $sReportName

# Log file decs
$sLogName = "$sScriptName.log"
$sLogFile = Join-Path -Path $sOutputDir -ChildPath $sLogName

# Transcript file decs
$sTranscriptName = "$sScriptName.transcript"
$sTranscriptFile = Join-Path -Path $sOutputDir -ChildPath $sTranscriptName

#-----------------------------------------------------------[Functions]------------------------------------------------------------

#-----------------------------------------------------------[Markdown]------------------------------------------------------------

if ($PSVersionTable.PSVersion.Major -ge 6) {
    Show-Markdown -Path "README.MD"
}
else {
    Write-Host $sScriptName -ForegroundColor Black -BackgroundColor White
    Write-Host "Version: $sScriptVersion" -ForegroundColor Black -BackgroundColor White
    Write-Host "Query the Yammer API to get a list of (active, suspended, and deleted) Yammer users." -ForegroundColor Black -BackgroundColor White
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Start-Transcript -Path $sTranscriptFile | Out-Null
Start-Log -LogPath $sOutputDir -LogName $sLogName -ScriptVersion $sScriptVersion | Out-Null

# SCRIPT START

$YammerReportZip = "C:\temp\YammerUserExport.zip"
$YammerReportZipExtract = "C:\temp\YammerUserExport"
$YammerReportZipExtractUsers = "C:\temp\YammerUserExport\Users.csv"

# https://learn.microsoft.com/en-us/rest/api/yammer/network-data-export
$URL = "https://www.yammer.com/api/v1/export?since=2013-11-25T00%3A00%3A00%2B00%3A00&model=User&include=csv"
# Register a Yammer application here https://www.yammer.com/client_applications
$YammerToken = Read-Host -Prompt "Enter your Yammer access token" -MaskInput

Invoke-RestMethod -Method Get -Uri $URL -Headers @{ Authorization = "Bearer $YammerToken" } -OutFile $YammerReportZip
Expand-Archive -Path $YammerReportZip -DestinationPath $YammerReportZipExtract
$YammerUsers = Import-CSV -Path $YammerReportZipExtractUsers -Delimiter ","

$Users = foreach ($YammerUser in $YammerUsers) {
    Write-Host "Processing '$($YammerUser.name)' (ID: $($YammerUser.id))"
    [PSCustomObject]@{
        EntraID         = $YammerUser.office_user_id
        ID              = $YammerUser.id
        State           = $YammerUser.state
        DisplayName     = $YammerUser.name
        UPN             = $YammerUser.email
        JobTitle        = $YammerUser.job_title
        Location        = $YammerUser.location
        Department      = $YammerUser.department
        ApiUrl          = $YammerUser.api_url
        Suspended       = $(if ($YammerUser.suspended_at) { $true } else { $false })
        SuspendedBy     = $YammerUser.suspended_by_id
        SuspendedByType = $YammerUser.suspended_by_type
        SuspendedAt     = $YammerUser.suspended_at
        Deleted         = $(if ($YammerUser.deleted_at) { $true } else { $false })
        DeletedBy       = $YammerUser.deleted_by_id
        DeletedByType   = $YammerUser.deleted_by_type
        DeletedAt       = $YammerUser.deleted_at
    }
}

Remove-Item $YammerReportZip -Force
Remove-Item $YammerReportZipExtract -Recurse -Force

Write-LogInfo -LogPath $sLogFile -Message "Get-YammerUsers: Writing report file to $sReportFile"
$Users | Export-Csv $sReportFile -NoTypeInformation

Write-Host "Report created in $sReportFile" -ForegroundColor Green

Read-Host -Prompt "Press enter to exit..." | Out-Null

# SCRIPT END
Stop-Log -LogPath $sLogFile
Stop-Transcript
