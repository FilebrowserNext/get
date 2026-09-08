#
#           File Browser Next Installer Script for Windows
#
#   GitHub: https://github.com/FilebrowserNext/filebrowserNEXT
#   Issues: https://github.com/FilebrowserNext/filebrowserNEXT/issues
#
#   Usage:
#       iwr -useb https://raw.githubusercontent.com/FilebrowserNext/get/main/get.ps1 | iex
#

function Install-FileBrowserNext {
    $ErrorActionPreference = "Stop"

    # Enforce TLS 1.2 for secure downloads
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Check administrator privileges
    $isAdmin = $false
    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($identity)
        $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch {
        $isAdmin = $false
    }

    # Determine installation directory based on privilege level
    if ($isAdmin) {
        $folder = Join-Path $env:ProgramFiles "File Browser Next"
        $pathTarget = [EnvironmentVariableTarget]::Machine
        Write-Host "Running as Administrator: installing system-wide to $folder..." -ForegroundColor Cyan
    } else {
        $baseFolder = if ($env:LOCALAPPDATA) { $env:LOCALAPPDATA } else { Join-Path $env:USERPROFILE "AppData\Local" }
        $folder = Join-Path (Join-Path $baseFolder "Programs") "File Browser Next"
        $pathTarget = [EnvironmentVariableTarget]::User
        Write-Host "Running as Standard User: installing to $folder..." -ForegroundColor Cyan
    }

    $file = "filebrowser-windows-amd64.zip"
    $url = "https://github.com/FilebrowserNext/filebrowserNEXT/releases/latest/download/$file"
    $tempZip = Join-Path $env:TEMP "filebrowser-next-$([Guid]::NewGuid().ToString('N')).zip"
    $tempExtract = Join-Path $env:TEMP "filebrowser-next-$([Guid]::NewGuid().ToString('N'))"

    Write-Host "Downloading File Browser Next from $url..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $url -OutFile $tempZip -UseBasicParsing

    Write-Host "Extracting archive..." -ForegroundColor Cyan
    if (Test-Path $tempExtract) {
        Remove-Item -Force -Recurse $tempExtract
    }
    Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force

    # Locate executable
    $binItem = Get-ChildItem -Path $tempExtract -Filter "*.exe" -Recurse | Where-Object { $_.Name -like "filebrowser*" } | Select-Object -First 1
    if (-not $binItem) {
        throw "Executable filebrowser.exe not found in extracted archive."
    }

    # Create target directory
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
    }

    $targetExe = Join-Path $folder "filebrowser.exe"
    Copy-Item -Path $binItem.FullName -Destination $targetExe -Force

    # Cleanup temporary files
    Remove-Item -Force $tempZip -ErrorAction SilentlyContinue
    Remove-Item -Force -Recurse $tempExtract -ErrorAction SilentlyContinue

    # Update system or user PATH
    Write-Host "Updating PATH environment variable..." -ForegroundColor Cyan
    $currentPath = [Environment]::GetEnvironmentVariable("Path", $pathTarget)
    if ($currentPath -notlike "*$folder*") {
        $separator = if ($currentPath.EndsWith(";")) { "" } else { ";" }
        [Environment]::SetEnvironmentVariable("Path", "$currentPath$separator$folder", $pathTarget)
        $env:Path += ";$folder"
    }

    Write-Host ""
    Write-Host "File Browser Next installed successfully." -ForegroundColor Green
    Write-Host "Installation path: $targetExe" -ForegroundColor Gray
    Write-Host ""
    Write-Host "To start the server, open a new terminal and run:" -ForegroundColor Yellow
    Write-Host "  filebrowser -r C:\path\to\your\files" -ForegroundColor White
    Write-Host ""
}

Install-FileBrowserNext
