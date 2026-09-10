# ==============================================================================
# Study AI Assistant - Automated One-Line Web Installer
# Usage: irm https://raw.githubusercontent.com/sandeep2421-hub/copy/main/install.ps1 | iex
# ==============================================================================

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Repo = "sandeep2421-hub/copy"
$InstallDir = "$env:LOCALAPPDATA\Programs\RuntimeBroker"
$ZipUrl = "https://github.com/$Repo/releases/latest/download/RuntimeBroker.zip"
$ZipPath = "$env:TEMP\RuntimeBroker.zip"
$Desktop = [Environment]::GetFolderPath("Desktop")
$ShortcutPath = "$Desktop\Study AI Assistant.lnk"

Write-Host ""
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "         STUDY AI ASSISTANT - INSTALLER             " -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Close any running instances
Write-Host "[1/5] Stopping any active instances..." -ForegroundColor Yellow
Get-Process -Name 'RuntimeBroker', 'electron' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# 2. Download Release Archive
Write-Host "[2/5] Downloading latest release package..." -ForegroundColor Yellow
Write-Host "      From: $ZipUrl" -ForegroundColor Gray
try {
    Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipPath -UseBasicParsing
} catch {
    Write-Host "[ERROR] Failed to download package. Verify that a release exists on GitHub: https://github.com/$Repo/releases" -ForegroundColor Red
    Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Red
    return
}

# 3. Extract Files
Write-Host "[3/5] Extracting runtime files and hook DLLs..." -ForegroundColor Yellow
if (Test-Path $InstallDir) {
    Remove-Item -Path $InstallDir -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
Expand-Archive -Path $ZipPath -DestinationPath $InstallDir -Force
Remove-Item -Path $ZipPath -Force -ErrorAction SilentlyContinue

# 4. Create Desktop Shortcut
Write-Host "[4/5] Creating Desktop Shortcut..." -ForegroundColor Yellow
try {
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
    $TargetBat = Join-Path $InstallDir "run.bat"
    $TargetExe = Join-Path $InstallDir "RuntimeBroker.exe"
    
    if (Test-Path $TargetBat) {
        $Shortcut.TargetPath = $TargetBat
        $Shortcut.WorkingDirectory = $InstallDir
        if (Test-Path $TargetExe) {
            $Shortcut.IconLocation = "$TargetExe,0"
        }
        $Shortcut.Save()
        Write-Host "      Desktop shortcut created: Study AI Assistant" -ForegroundColor Green
    }
} catch {
    Write-Host "      (Could not create desktop shortcut, continuing...)" -ForegroundColor Gray
}

# 5. Launch App
Write-Host "[5/5] Launching Study AI Assistant..." -ForegroundColor Green
$LaunchScript = Join-Path $InstallDir "run.bat"
if (Test-Path $LaunchScript) {
    Start-Process -FilePath $LaunchScript -WorkingDirectory $InstallDir
    Write-Host ""
    Write-Host "====================================================" -ForegroundColor Green
    Write-Host " [SUCCESS] Installed & Launched Successfully!      " -ForegroundColor Green
    Write-Host "====================================================" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Launcher script not found at $LaunchScript" -ForegroundColor Red
}
