# wmassingham@truenorthnetworks.com 2017-05-17

# FQDN of your N-Central server
$server = "https://n-central.whatever.example/"
# Customer ID, from Administration > Customers
$custid = ''
# Directory to save the agent installer
$dir = $env:temp

# Check to see if agent already installed
if (Test-Path 'C:\Program Files (x86)\N-able Technologies\Windows Agent\bin\agent.exe') {
	Write-Host 'File C:\Program Files (x86)\N-able Technologies\Windows Agent\bin\agent.exe already exists, exiting'
	exit 0
}
if (Test-Path 'C:\Program Files\N-able Technologies\Windows Agent\bin\agent.exe') {
	Write-Host 'File C:\Program Files\N-able Technologies\Windows Agent\bin\agent.exe already exists, exiting'
	exit 0
}

# Remove the installer, in case we've tried this before
Remove-Item "$dir\WindowsAgentSetup.exe" -Force -Erroraction SilentlyContinue

# Download the agent
try {
	Write-Host "Downloading generic agent installer"
	$WebClient = New-Object System.Net.WebClient
	$WebClient.DownloadFile(("https://$server/download/current/winnt/N-central/WindowsAgentSetup.exe", "$dir\WindowsAgentSetup.exe")
} catch {
	Write-Error "Failed to download agent installer: " $_.Exception.Message
	exit 1
}

# Run the installer
try {
	# passing parameters gets complicated, there needs to be a space inside the double quotes, but not between the v and the quotes
	# see https://secure.n-able.com/webhelp/NC_11-0-0_en/Content/Help_20/Deploying/SoftwareInstallCommandPrompt.htm
	# additionally, if we're not on a domain, we must not pass the AGENTDOMAIN parameter, regardless of value, or the installer will fail
	$params = "/s /v`" /qn CUSTOMERID=$custid CUSTOMERSPECIFIC=1 SERVERPROTOCOL=HTTPS SERVERADDRESS=$server SERVERPORT=443 `""
	Write-Host "Executing, parameters: $params"
	Start-Process "$dir\WindowsAgentSetup.exe" -ArgumentList $params #-Wait
} catch {
	Write-Error "Failed to install agent: " $_.Exception.Message
	exit 1
}

Write-Host "Install appears to have completed. If there appears to be a problem, consult the Application event log."
