# Set-ExecutionPolicy
Set-ExecutionPolicy Unrestricted -Force

#Set Directory
$PSDefaultParameterValues = @{"Invoke-AtomicTest:PathToAtomicsFolder"="C:\Users\Public\Downloads\tmp\atomics"}

#Download Payload
$webClient = New-Object System.Net.WebClient

# Download and execute install-atomicredteam.ps1
$scriptBytes = $webClient.DownloadData('https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1')
$scriptString = [System.Text.Encoding]::UTF8.GetString($scriptBytes)
Invoke-Expression -Command $scriptString
Install-AtomicRedTeam -InstallPath "C:\Users\Public\Downloads\tmp" -Force

# Download and execute install-atomicsfolder.ps1
$scriptBytes = $webClient.DownloadData('https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicsfolder.ps1')
$scriptString = [System.Text.Encoding]::UTF8.GetString($scriptBytes)
Invoke-Expression -Command $scriptString
Install-AtomicsFolder -InstallPath "C:\Users\Public\Downloads\tmp" -Force

#Load framework
Install-Module -Name invoke-atomicredteam,powershell-yaml -Force
Import-Module -Name invoke-atomicredteam,powershell-yaml -Force

#Atomics
Invoke-AtomicTest T1078.003-1 -Verbose -Force
Invoke-AtomicTest T1573 -Verbose -Force
Invoke-AtomicTest T1518.001-1 -Verbose -Force
Invoke-AtomicTest T1218.002 -Verbose -Force
Invoke-AtomicTest T1113-2 -Verbose -Force

#Clean up
Remove-Item -LiteralPath "C:\Users\Public\Downloads\tmp" -Force -Recurse