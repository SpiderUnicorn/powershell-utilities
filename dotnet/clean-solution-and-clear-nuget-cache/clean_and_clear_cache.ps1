<#
.SYNOPSIS
Removes all bin and object folders and clears nuget cache.

.PARAMETER solutionDir
The solution to clean. If no directory is provided, The
location of the script is used as the root.

.PARAMETER nugetExe
Path to the nuget executable. If no path is provided,
nuget.exe will be downloaded to perform the cache clear,
and then removed.
#>


Param(
  [string]$solutionDir = $PSScriptRoot,
  [string]$nugetExe
)

function CheckAndWarnForVisualStudioInstance {
    while (Get-Process devenv -ErrorAction SilentlyContinue)    {
        Write-Host "An instance of visual studio is found running"
        $confirm = Read-Host "Close visual studio and press enter to continue [q to quit]"
        if ($confirm -eq 'q') {
            exit
        }
    }
}

function RemoveBinAndObjDirectories {
   Write-Host "Cleaning (removing) bin & obj"
   $params = @{
     Directory = $true
     Include = 'bin','obj'
     Recurse = $true
     Depth = 2
   }
    Get-ChildItem $solutionDir @params | 
        Remove-Item -Recurse -Force
}

function RemoveFragmentAndLockFiles {
    Write-Host "Removing all fragment & lock files"
    $params = @{
        File = $true
        Include = 'project.lock.json','project.fragment.json','project.fragment.lock.json'
        Recurse = $true
        Depth = 2
    }
    Get-ChildItem $solutionDir @params | 
        Remove-Item -Force
}

function ClearNugetCache {
    # download nuget
    $output = $nugetExe
    if (!$output) {
        Write-Host "Downloading nuget.exe"
        $url = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
        $output = "$PSScriptRoot\nuget.exe"
        (New-Object System.Net.WebClient).DownloadFile($url, $output)
    }

    # invoke clear all
    Write-Host "Clearing local cache"
    Invoke-Expression "$($output) locals all -clear"

    if (!$output) {
        Write-Host "Cleaning up..."
        Remove-Item $output
    }
}

CheckAndWarnForVisualStudioInstance
RemoveBinAndObjDirectories
RemoveFragmentAndLockFiles
ClearNugetCache
