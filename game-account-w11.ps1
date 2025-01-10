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

# Proceed only if elevated
# Check if the file exists
$fileToDelete = "C:\Users\Public\Documents\gaming-account-loader.ps1"
if (Test-Path $fileToDelete) {
    # Delete the file
    Remove-Item -Path $fileToDelete -Force
    Write-Host "File has been deleted: $fileToDelete"
} else {
    Write-Host "File not found: $fileToDelete"
}

# Download the Loader script for the account
$url = "https://raw.githubusercontent.com/Operator-One/GameAccount-W11/refs/heads/main/gaming-account-loader.ps1"
$output = "C:\Users\Public\Documents\gaming-account-loader.ps1"

# Download the file
Invoke-WebRequest -Uri $url -OutFile $output
Write-Host "File downloaded to $output"

# Define the new user account details
$username = "Gaming-Account"

# Create the new user account without a password
New-LocalUser -Name $username -NoPassword -AccountNeverExpires

# Flag the user account to require a password change at next login
Set-LocalUser -Name $username -UserMayNotChangePassword $false -PasswordNeverExpires $false -AccountExpires ([datetime]::Now.AddDays(1))
net user $username /logonpasswordchg:yes

# Add the user to the 'Users' group
Add-LocalGroupMember -Group "Users" -Member $username

# Path to the PowerShell script to be run at login
$scriptPath = "C:\Users\Public\Documents\gaming-account-loader.ps1"

# Create a scheduled task to run the script at login
$taskName = "RunProgramLoader"
$taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$scriptPath`""
$taskTrigger = New-ScheduledTaskTrigger -AtLogOn -User $username
$taskPrincipal = New-ScheduledTaskPrincipal -UserId $username -LogonType Interactive -RunLevel Limited
$taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName $taskName -Action $taskAction -Trigger $taskTrigger -Principal $taskPrincipal -Settings $taskSettings

Write-Host "User 'Gaming-Account' created and scheduled task set up to run 'gaming-account-loader.ps1' at login. The user will be prompted to change their password at next login."
