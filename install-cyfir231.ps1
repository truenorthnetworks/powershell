# KB - 90064 - Install CyFIR 2.3.1
# 2018-10-25 wmassingham@truenorthnetworks.com

Set-StrictMode -Version 3.0

$workdir = "c:\temp\"
$installer = "CyFIRAgent-2.3.1.11229.25379.exe"
$timestampfile = "$workdir\cyfir22uninstall.txt"

function Get-PatchDay() {

	switch ($ENV:PROCESSOR_ARCHITECTURE) {
		"x86"   { $agentpath = "C:\Program Files\N-able Technologies\Windows Agent\";       break; }
		"AMD64" { $agentpath = "C:\Program Files (x86)\N-able Technologies\Windows Agent\"; break; }
		default { throw "Unsupported architecture: $ENV:PROCESSOR_ARCHITECTURE";            break; }
	}

	$var1 = $True
	$var2 = ""

	#Parse XML file at C:\Program Files (x86)\N-able Technologies\Windows Agent\Config\
	[xml]$xml = get-content "$agentpath\Config\AgentMaintenanceSchedules.xml"
	$textToParse = ($xml.AgentMaintenanceSchedules.MaintenanceSchedules).Replace("{", "").Replace("}", "").Replace("[", "").Replace("]", "").Replace(",", "")
	$textToParse = $textToParse.Split("`n")
	$i = 0
	while ($i -lt $textToParse.Length) {
		if ($textToParse[$i].Trim() -match "          `"Feature`": `"PatchManagement`"".trim()) {
			if ($textToParse[$i + 2].Trim() -match "            `"Install`"".trim()) {
				$var2 = $textToParse[$i - 6].split(":")[1].replace("`"", "")
				break
			}
		}
		$i++
	}

	# Determine if PatchManagementEnabled is true or false  
	if ($var1 -eq $False) {
		throw "No patch schedule detected."
	} else {
		#$API_key = "0 15 10 ? * 6#3" | out-string
		$API_key = $var2 | out-string
		# convert the pound symbol to %23 so that the web server understands
		$API_key = $API_key.Replace("#", "%23")
		$url = "http://www.cronmaker.com/rest/sampler?count=1&expression=$API_key"
		#Store the results in $return

		$WebRequest = [System.Net.WebRequest]::Create($url)
		$WebRequest.Method = "GET"
		$WebRequest.ContentType = "application/json"
		$Response = $WebRequest.GetResponse()
		$ResponseStream = $Response.GetResponseStream()
		$ReadStream = New-Object System.IO.StreamReader $ResponseStream

		return $ReadStream.ReadToEnd()
	}
}

<#
if ($waitforpatch -ne "false") {
	
	if (-not (Test-Path variable:patchdays)) { $patchdays = 30 }

	# Check to see if the next patch day is within seven days
	try {
		if ((Get-Date).AddDays($patchdays) -lt (Get-PatchDay)) {
			Write-Host "Patch day is more than $patchdays days out, exiting"
			exit 0
		}
	} catch {
		Write-Error ("Failed to get-patchday: " + $_.Exception.Message)
		exit 1
	}

}
#>

# Check to see if 2.2 is still installed, and if so, uninstall it and wait for reboot
Write-Host "Checking for CyFIR version"
try {
	# cyfir lives in these two folders depending on architecture
	switch ($ENV:PROCESSOR_ARCHITECTURE) {
		"x86"   { $cyfirdir = "C:\Windows\system32\CyFIRAgent\"; break; }
		"AMD64" { $cyfirdir = "C:\WINDOWS\SysWOW64\CyFIRAgent\"; break; }
		default { throw "Unsupported architecture: $ENV:PROCESSOR_ARCHITECTURE"; break; }
	}

	# we can check for the existence of the 2.3 cert to identify version
	if (test-path "$cyfirdir\keys\client\af09dc9d834faa8cccb143096a6cd3214467d7c7\cert.pem") {
		Write-Host "CyFIR 2.3 cert found, assuming 2.3 installed, exiting"
		exit 0
	} else {
		Write-Host "CyFIR 2.3 cert not found, looking for any version"
		if (test-path "$cyfirdir\AgentManager.exe") {
			Write-Host "CyFIR AgentManager.exe found, attempting uninstall of 2.2"
			Start-Process "$workdir\CyFIRAgent-2.2.0.8758.20952.exe" -ArgumentList "/u" -Wait

			# Write out the uninstall date
			Get-Date -Format "o" | Out-File $timestampfile
			Write-Host "CyFIR 2.2 has been uninstalled, exiting"
			exit 0
		} else {
			Write-Host "No version of CyFIR found installed"
		}
	}
} catch {
	Write-Error ("Failed to check/uninstall CyFIR 2.2: " + $_.Exception.Message)
	exit 1
}

# CyFIR 2.2 was not found, check for uninstall timestamp
try {
	if (Test-Path $timestampfile) {
		$lastboot = (Get-CimInstance -ClassName win32_operatingsystem | Select-Object lastbootuptime).lastbootuptime
		if ((Get-Content $timestampfile | get-date) -gt $lastboot) {
			# Timestamp is later than last boot, exit
			Write-Host "PC has not been rebooted since CyFIR 2.2 uninstall, exiting"
			exit 0
		}
	} else {
		Write-Host "2.2 uninstall timestamp not found, assuming never installed"
	}
} catch {
	Write-Error ("Failed to check uninstall timestamp: " + $_.Exception.Message)
	exit 1
}

# Run installer
try {
	$params = "/i proxy:162.218.106.112 port:30000 hash:af09dc9d834faa8cccb143096a6cd3214467d7c7 security:0 logging:1"
	Start-Process "$workdir\$installer" -ArgumentList $params -Wait
} catch {
	Write-Error ("Failed to run CyFIR 2.3 installer: " + $_.Exception.Message)
	exit 1
}

Write-Host "Install appears to have completed. If there appears to be a problem, consult the Application event log."
Write-Host "For your convenience, the last 10 events are shown below."

Get-EventLog -Newest 10 -LogName "Application" | Format-Table | Out-String
