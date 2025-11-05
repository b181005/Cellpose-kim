<#
One-time environment installer for Windows PowerShell.
Creates a virtual environment, installs packages from requirements.txt (if present),
and writes a marker file so it won't run again unless forced.

Usage examples (PowerShell):
  # Run once
  .\scripts\install_env.ps1

  # Force re-run
  .\scripts\install_env.ps1 -Force

Parameters:
  -EnvName: directory name for the virtual environment (default: .venv)
  -ReqFile: path to requirements file (default: requirements.txt)
  -Force: re-run even if marker exists
#>
param(
    [string]$EnvName = ".venv",
    [string]$ReqFile = "requirements.txt",
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$markerFile = Join-Path $scriptRoot ".env_installed_$EnvName"

function Write-Info($msg){ Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Err($msg){ Write-Host "[ERROR] $msg" -ForegroundColor Red }

Write-Info "Installer started. Env: '$EnvName'  Requirements: '$ReqFile'"

if (Test-Path $markerFile -and -not $Force) {
    Write-Info "Marker file found at '$markerFile'. Installation already completed. Use -Force to re-run."
    return
}

# Check python availability
$pyCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pyCmd) {
    Write-Err "Python executable not found in PATH. Please install Python 3.8+ and make sure 'python' is on PATH."
    exit 1
}

# Create virtual environment
try {
    Write-Info "Creating virtual environment at '$EnvName'..."
    & python -m venv $EnvName
} catch {
    Write-Err "Failed to create venv: $_"
    exit 1
}

# Locate venv pip/python
$venvPip = Join-Path $EnvName "Scripts\pip.exe"
$venvPython = Join-Path $EnvName "Scripts\python.exe"
if (-not (Test-Path $venvPip)) {
    Write-Err "pip not found in venv at '$venvPip'. The venv may not have been created correctly."
    exit 1
}

# Upgrade pip
try {
    Write-Info "Upgrading pip in venv..."
    & $venvPip install --upgrade pip
} catch {
    Write-Err "Failed to upgrade pip: $_"
    # continue; not fatal
}

# Install packages
if (Test-Path (Join-Path $scriptRoot $ReqFile)) {
    $reqPath = Join-Path $scriptRoot $ReqFile
    Write-Info "Installing packages from '$reqPath'..."
    try {
        & $venvPip install -r $reqPath
    } catch {
        Write-Err "pip install failed: $_"
        exit 1
    }
} else {
    Write-Info "No requirements file found at '$ReqFile'. Installing example common packages..."
    try {
        & $venvPip install numpy scipy matplotlib opencv-python
    } catch {
        Write-Err "pip install failed: $_"
        exit 1
    }
}

# Mark as installed
try {
    $timestamp = Get-Date -Format o
    "Installed on $timestamp`nEnv: $EnvName`nReqFile: $ReqFile" | Out-File -FilePath $markerFile -Encoding utf8
    Write-Info "Installation complete. Marker written to '$markerFile'."
} catch {
    Write-Err "Failed to write marker file: $_"
}

Write-Host "`nNEXT STEPS:" -ForegroundColor Green
Write-Host "To activate the virtual environment (PowerShell):"
Write-Host "  Set-Location $scriptRoot"
Write-Host "  .\\$EnvName\\Scripts\\Activate.ps1"
Write-Host "Then run your scripts or Jupyter. To exit, run 'deactivate' or close the shell." -ForegroundColor Green

Write-Host "If you prefer conda, see README_INSTALL.md for a conda alternative."
