Set-StrictMode -v latest
$ErrorActionPreference = "Stop"

function Main()
{
    Clean-Folder "/mnt/ramdisk/tcagent/work" 16 5
}

function Clean-Folder([string] $folderpath, [int] $namelength, [int] $keep)
{
    if (!(Test-Path $folderpath))
    {
        Log ("Didn't find: '" + $folderpath + "'")
        return
    }

    $folders = @(dir $folderpath | ? { $_.Name.Length -eq $namelength } | Sort-Object LastWriteTime -desc | select -Skip $keep)
    Log ("Found " + $folders.Count + " old folders in '" + $folderpath + "'")
    $folders | % {
        Log ("Deleting: '" + $_.FullName + "'")
        del -Recurse -Force $_.FullName -ErrorAction SilentlyContinue
        if (Test-Path $_.FullName)
        {
            Log ("Couldn't delete folder: '" + $_.FullName + "'") Red
        }
    }
}

function Log([string] $message, $color)
{
    $now = [DateTime]::UtcNow
    if ($color)
    {
        Write-Host ($now.ToString("yyyy-MM-dd HH:mm:ss") + ": " + $message) -f $color
    }
    else
    {
        Write-Host ($now.ToString("yyyy-MM-dd HH:mm:ss") + ": " + $message) -f Green
    }
}

Main
