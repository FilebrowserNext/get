#Requires -RunAsAdministrator 
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

    $file = "filebrowser-windows-amd64.zip"
    $url = "https://github.com/FilebrowserNext/filebrowserNEXT/releases/latest/download/$file"
    $tempZip = Join-Path $env:TEMP "filebrowser-next.zip"
    $tempExtract = Join-Path $env:TEMP "filebrowser-next-extract"
    $folder = "${env:ProgramFiles}\File Browser Next"

    Write-Host "Downloading File Browser Next from $url..." -ForegroundColor Cyan
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $url -OutFile $tempZip -UseBasicParsing

    Write-Host "Extracting archive..." -ForegroundColor Cyan
    if (Test-Path $tempExtract) {
        Remove-Item -Force -Recurse $tempExtract
    }
    Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force

    Write-Host "Installing to $folder..." -ForegroundColor Cyan
    if (-not (Test-Path $folder)) {
        New-Item -ItemType "directory" -Path $folder | Out-Null
    }

    $binSrc = Join-Path $tempExtract "filebrowser.exe"
    if (-not (Test-Path $binSrc)) {
        $altSrc = Join-Path $tempExtract "filebrowser-windows-amd64.exe"
        if (Test-Path $altSrc) {
            $binSrc = $altSrc
        }
    }

    Copy-Item -Path $binSrc -Destination (Join-Path $folder "filebrowser.exe") -Force

    Write-Host "Cleaning up temporary files..."
    Remove-Item -Force $tempZip -ErrorAction SilentlyContinue
    Remove-Item -Force -Recurse $tempExtract -ErrorAction SilentlyContinue

    Write-Host "Adding File Browser Next to system PATH..." -ForegroundColor Cyan
    $machinePath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
    if ($machinePath -notlike "*$folder*") {
        [Environment]::SetEnvironmentVariable("Path", "$machinePath;$folder", [EnvironmentVariableTarget]::Machine)
        $env:Path += ";$folder"
    }

    Write-Host "File Browser Next installed successfully." -ForegroundColor Green
    Write-Host "Open a new terminal and run: filebrowser -r C:\path\to\your\files" -ForegroundColor Yellow
}

Install-FileBrowserNext
