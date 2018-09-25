# wmassingham@truenorthnetworks.com 2018-09-19

# Directory to save the agent installer
$dir = $env:temp

# Remove the installer, in case we've tried this before
Remove-Item "$dir\WindowsAgentSetup.exe" -Force -Erroraction SilentlyContinue

# Get the existing config info to build the activation key
$serverconfig = ([xml](Get-Content "C:\Program Files (x86)\N-able Technologies\Windows Agent\config\ServerConfig.xml")).ServerConfig
$applianceconfig = ([xml](Get-Content "C:\Program Files (x86)\N-able Technologies\Windows Agent\config\ApplianceConfig.xml")).ApplianceConfig

# Download the agent
try {
	Write-Host "Downloading generic agent installer"
	$WebClient = New-Object System.Net.WebClient
	$WebClient.DownloadFile($serverconfig.Protocol+"://"+$serverconfig.ServerIP+":"+$serverconfig.Port+"/download/current/winnt/N-central/WindowsAgentSetup.exe", "$dir\WindowsAgentSetup.exe")
} catch {
	Write-Error "Failed to download agent installer: " $_.Exception.Message
	exit 1
}

$Text = ($serverconfig.Protocol+"://"+$serverconfig.ServerIP+":"+$serverconfig.Port+"|"+$applianceconfig.ApplianceID+"|1|0")
$activationkey = [Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($Text))

# Run the installer
try {
	# passing parameters gets complicated, there needs to be a space inside the double quotes, but not between the v and the quotes
	# see https://secure.n-able.com/webhelp/NC_11-0-0_en/Content/Help_20/Deploying/SoftwareInstallCommandPrompt.htm
	# additionally, if we're not on a domain, we must not pass the AGENTDOMAIN parameter, regardless of value, or the installer will fail
	$params = " /v`" AGENTACTIVATIONKEY=$activationkey `""
	Write-Host "Executing, parameters: $params"
	Start-Process "$dir\WindowsAgentSetup.exe" -ArgumentList $params -Wait
} catch {
	Write-Error "Failed to install agent: " $_.Exception.Message
	exit 1
}

Write-Host "Install appears to have completed. If there appears to be a problem, consult the Application event log."
