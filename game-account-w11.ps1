
# Download the loader script from Github 
$url = "https://github.com/your-repository/your-script.ps1" 
$output = "C:\Users\Public\Documents\gaming-account-loader.ps1" 
# Download the file 
Invoke-WebRequest -Uri $url -OutFile $output 
Write-Host "File downloaded to $output"

# Define the new user account details
$username = "Gaming Account"
$password = "GamerPassword!@12"

# Create the new user account
New-LocalUser -Name $username -Password (ConvertTo-SecureString $password -AsPlainText -Force) -AccountNeverExpires -UserMayNotChangePassword $false
Add-LocalGroupMember -Group "Users" -Member $username

# Force the user to change their password at next logon
Set-LocalUser -Name $username -PasswordNeverExpires $false -UserMayChangePassword $true -AccountExpires ([datetime]::Now.AddDays(1))

# Path to the PowerShell script to be run at login
$scriptPath = "C:\Users\Public\Documents\gaming-account-loader.ps1"

# Create a scheduled task to run the script at login
$taskName = "RunProgramLoader"
$taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$scriptPath`""
$taskTrigger = New-ScheduledTaskTrigger -AtLogOn -User $username
$taskPrincipal = New-ScheduledTaskPrincipal -UserId $username -LogonType Interactive -RunLevel Limited
$taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName $taskName -Action $taskAction -Trigger $taskTrigger -Principal $taskPrincipal -Settings $taskSettings

Write-Host "User 'Gaming Account' created and scheduled task set up to run 'program-loader.ps1' at login. The user will be prompted to change their password at next login."
