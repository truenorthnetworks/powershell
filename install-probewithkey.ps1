# Customer name needs escaped quotation marks around it
$custname = '\"' + $deviceinfo.CustomerName + '\"'
$custid = $deviceinfo.CustomerID
#>

# Our working dir, in case it doesn't exist
New-Item "C:\temp\" -ItemType directory -Force | Out-Null

# Remove the installer, in case we've tried this before
Remove-Item "C:\temp\WindowsProbeSetup.exe" -Force -Erroraction SilentlyContinue

$useDomain = ![string]::IsNullOrWhitespace($agentdomain)

# Set up validation depending on whether we're using AD or local accounts
Add-Type -assemblyname system.DirectoryServices.accountmanagement
$DS = $null

#if ($useDomain) {
if($env:userdomain -ne "WORKGROUP") {
	# We are on a domain, use AD
	Write-Host "Validating AD account credentials"
	$DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Domain)
} else {
	# Not on a domain, use local account
	Write-Host "Validating local account credentials"
	$DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine)
}

# Validate the credentials
if ($DS.ValidateCredentials($agentusername, $agentpassword)) {
	Write-Host "Successfully validated account credentials"
} else {
	Write-Error "Error: Failed to validate account credentials!"
	Write-Error "Please confirm account exists and is using the specified credentials."
	exit 1
}

# Download the probe
try {
	Write-Host "Downloading generic probe installer"
	$WebClient = New-Object System.Net.WebClient
	$WebClient.DownloadFile("https://n-able.secureworkplace.net/download/current/winnt/N-central/WindowsProbeSetup.exe", "C:\temp\WindowsProbeSetup.exe")
} catch {
	Write-Error "Failed to download probe installer: " $_.Exception.Message
	exit 1
}

# Run the installer
try {
	# passing parameters gets complicated, there needs to be a space inside the double quotes, but not between the v and the quotes
	# see https://secure.n-able.com/webhelp/NC_11-0-0_en/Content/Help_20/Deploying/SoftwareInstallCommandPrompt.htm
	# additionally, if we're not on a domain, we must not pass the AGENTDOMAIN parameter, regardless of value, or the installer will fail
	if ($env:userdomain -ne "WORKGROUP") {
		$params = "/s /v`" /qn AGENTACTIVATIONKEY=$activationkey SERVERPROTOCOL=HTTPS SERVERADDRESS=n-able.secureworkplace.net SERVERPORT=443 PROBETYPE=Network_Windows AGENTDOMAIN=$env:userdomain AGENTUSERNAME=$agentusername AGENTPASSWORD=$agentpassword `""
	} else {
		$params = "/s /v`" /qn AGENTACTIVATIONKEY=$activationkey SERVERPROTOCOL=HTTPS SERVERADDRESS=n-able.secureworkplace.net SERVERPORT=443 PROBETYPE=Workgroup_Windows AGENTUSERNAME=$agentusername AGENTPASSWORD=$agentpassword `""
	}
	Write-Host "Executing probe installer"
	Start-Process "C:\temp\WindowsProbeSetup.exe" -ArgumentList $params -Wait
} catch {
	Write-Error "Failed to install probe: " $_.Exception.Message
	exit 1
}

Write-Host "Install appears to have completed. If there appears to be a problem, consult the Application event log."
Write-Host "For your convenience, the last 20 events are shown below."

Get-EventLog -Newest 20 -LogName "Application" | Format-Table | Out-String
