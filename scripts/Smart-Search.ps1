<#
.SYNOPSIS
    Searches a folder (and its subfolders) for files and folders by name.

.PARAMETER SearchPath
    Folder to search. Default: the current folder.

.PARAMETER LogPath
    Where to save the log. Can be a file or a folder. Default: Smart-SearchLog.txt in the current folder.

.PARAMETER CaseSensitive
    Match upper and lower case exactly.

.EXAMPLE
    .\Smart-Search.ps1 -SearchPath C:\Tools -LogPath D:\Logs -CaseSensitive
#>
param(
    [string]$SearchPath = (Get-Location).Path,
    [string]$LogPath    = (Join-Path (Get-Location).Path "Smart-SearchLog.txt"),
    [switch]$CaseSensitive
)

function Show-Usage {
    param(
        [string]$SearchPath,
        [string]$LogPath,
        [bool]$CaseSensitive
    )

    $Mode = if ($CaseSensitive) { 'case sensitive' } else { 'case insensitive' }

    Write-Host "Current search:" -ForegroundColor Cyan
    Write-Host " .\Smart-Search.ps1 -SearchPath $SearchPath -LogPath $LogPath -CaseSensitive"
    Write-Host ""
}

function Smart-Search {
    param(
        [string]$SearchPath,
        [string]$LogPath,
        [bool]$CaseSensitive
    )

    if (-not (Test-Path -LiteralPath $SearchPath -PathType Container)) {
        Write-Host "Search folder not found: $SearchPath" -ForegroundColor Red
        return
    }
    $SearchPath = (Resolve-Path -LiteralPath $SearchPath).Path

    # Turn a relative log path into a full one, so the settings show where it really goes
    $LogPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($LogPath)

    # If a folder was given for the log, put the log file inside it.
    # A path that doesn't exist yet counts as a folder when it ends in \ or has no extension.
    $IsFolder = (Test-Path -LiteralPath $LogPath -PathType Container) -or
                ($LogPath -match '[\\/]$') -or
                (-not [System.IO.Path]::HasExtension($LogPath))
    if ($IsFolder) {
        $LogPath = Join-Path $LogPath "Smart-SearchLog.txt"
    }

    # Create the log's folder if it doesn't exist yet
    $LogFolder = Split-Path $LogPath -Parent
    if ($LogFolder -and -not (Test-Path -LiteralPath $LogFolder)) {
        New-Item -ItemType Directory -Path $LogFolder -Force | Out-Null
    }

    Show-Usage -SearchPath $SearchPath -LogPath $LogPath -CaseSensitive $CaseSensitive

    $Mode = if ($CaseSensitive) { 'case sensitive' } else { 'case insensitive' }

    do {
        Write-Host ""
        $UserInput = Read-Host "What do you want to search?"
        if ([string]::IsNullOrWhiteSpace($UserInput)) {
            Write-Host "Please enter a search term."
            $Answer = 'y'
            continue
        }

        $Results = Get-ChildItem -LiteralPath $SearchPath -Recurse -Filter "*$UserInput*" -ErrorAction SilentlyContinue

        # -Filter ignores case, so narrow the results down with -clike
        if ($CaseSensitive) {
            $Pattern = "*" + [WildcardPattern]::Escape($UserInput) + "*"
            $Results = $Results | Where-Object { $_.Name -clike $Pattern }
        }

        if ($Results) {
            # Blank line between searches in the log (skipped for a new, empty log)
            if ((Test-Path -LiteralPath $LogPath) -and (Get-Item -LiteralPath $LogPath).Length -gt 0) {
                "" | Out-File -LiteralPath $LogPath -Append
            }
            "--- $(Get-Date) : '$UserInput' in $SearchPath ($Mode) ---" | Out-File -LiteralPath $LogPath -Append
            $Results | ForEach-Object {
                if ($_.PSIsContainer) { "[DIR]  $($_.FullName)" } else { "       $($_.FullName)" }
            } | Tee-Object -FilePath $LogPath -Append
        } else {
            Write-Host "No results"
        }

        do {
            $Answer = Read-Host 'Would you like to search again? y/n'
        } until ($Answer -in 'y', 'n')

    } while ($Answer -eq 'y')
}

Smart-Search -SearchPath $SearchPath -LogPath $LogPath -CaseSensitive $CaseSensitive.IsPresent
