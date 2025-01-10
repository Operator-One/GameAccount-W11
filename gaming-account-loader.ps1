# Function to check if running as administrator
function Test-Administrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Elevate the script if not running as administrator
if (-not (Test-Administrator)) {
    Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Installations for Windows Store Apps might be limited to the user account, so this pulls the apps again just in-case. 

# Install Discord from winget
Start-Process -Wait -NoNewWindow winget install Discord.Discord

# Install Spotify
Start-Process -Wait -NoNewWindow winget install Spotify.Spotify

# Install OBS Studio
Start-Process -Wait -NoNewWindow winget install OBSProject.OBSStudio

$programs = @(
    "Open Steam",
    "Open Discord",
    "Open MSEdge",
    "Open Spotify",
    "Open OBS Studio",
    "Open Notepad",
    "Disable Windows Explorer",
    "Enable Windows Explorer",
    "Exit"
)

function Disable-WindowsExplorer {
    $registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    $registryName = "NoDesktop"

    if (-not (Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force
    }

    Set-ItemProperty -Path $registryPath -Name $registryName -Value 1
    Write-Host "Windows Explorer has been disabled for this user account."
}

function Enable-WindowsExplorer {
    $registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    $registryName = "NoDesktop"

    Remove-ItemProperty -Path $registryPath -Name $registryName -ErrorAction SilentlyContinue
    Write-Host "Windows Explorer has been re-enabled for this user account."
}

while ($true) {
    Clear-Host
    Write-Host "Please select a program to execute:"
    for ($i = 0; $i -lt $programs.Count; $i++) {
        Write-Host "$($i + 1). $($programs[$i])"
    }

    $selection = Read-Host "Enter the number of your choice"
    $index = [int]$selection - 1

    if ($index -ge 0 -and $index -lt $programs.Count) {
        switch ($programs[$index]) {
            "Exit" {
                Write-Host "Exiting..."
                break
            }
            "Disable Windows Explorer" {
                Disable-WindowsExplorer
            }
            "Enable Windows Explorer" {
                Enable-WindowsExplorer
            }
            "Open Steam" {
                Start-Process "Steam"
            }
            "Open Discord" {
                Start-Process "Discord"
            }
            "Open MSEdge" {
                Start-Process "msedge"
            }
            "Open Spotify" {
                Start-Process "Spotify"
            }
            "Open OBS Studio" {
                Start-Process "OBS Studio"
            }
            "Open Notepad" {
                Start-Process "notepad"
            }
            default {
                Write-Host "Invalid selection, please try again."
            }
        }
    } else {
        Write-Host "Invalid selection, please try again."
    }

    Start-Sleep -Seconds 2
}
