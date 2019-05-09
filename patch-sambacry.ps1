# Script to get and install patch for SambaCry
# wmassingham@truenorthnetworks.com, 2017-06-23

function check-hotfix {
	# there is sometimes a bug in n-able where double characters get changed to
	# triple or single characters, so these strings are split to avoid that
	$hotfixes = ('KB402' + '2719'), ('KB402' + '272' + '2'), ('KB402'+'2724'), ('402'+'2718')
	
	#$hotfix = Get-HotFix -Id $hotfixes | Select-Object -First 1 -ExpandProperty 'HotFixID'
	$hotfix = Get-HotFix | 
		Where-Object -FilterScript { $hotfixes -contains $_.HotfixID } | 
		Select-Object -ExpandProperty 'HotFixID'
	
	# Windows 10 Creators Update is fine without any KB, so hack it in
	try {
		if ([int](Get-CimInstance Win32_OperatingSystem).buildnumber -ge 15063) { $hotfix = 'KBWindows10' }
	} catch {
		#write-host 'error getting cim instance, trying wmi'
		if ([int](Get-WmiObject Win32_OperatingSystem).buildnumber -ge 15063) { $hotfix = 'KBWindows10' }
	}
	
	if ($hotfix -like "KB*") {
		return $hotfix
	} else {
		return ""
	}
	
}

Write-Host "Device: $env:computername"

$arch = $ENV:PROCESSOR_ARCHITECTURE
$os = (Get-WmiObject -class Win32_OperatingSystem).caption

#Write-Host "Detecting operating system..."

#""     { $link = ""; break; }

switch ($arch) {
	"AMD64" {
		Write-Host "Operating system: $os 64-bit"
		switch -wildcard ($os) {
			"Microsoft*2008*R2*" { $link = "http://download.windowsupdate.com/c/msdownload/update/software/secu/2017/06/windows6.1-kb4022722-x64_ee5b5fae02d1c48dbd94beaff4d3ee4fe3cd2ac2.msu"; break; }
			"Microsoft*2012*" { $link = "http://download.windowsupdate.com/d/msdownload/update/software/secu/2017/06/windows8-rt-kb4022718-x64_fb200a5c5c54a6a78f02d569a1fb31e2f5553dd7.msu"; break; }
			default { throw "Unsupported OS: $os" }
		}
		break;
	}
	default {
		throw "Unsupported architecture: $ENV:PROCESSOR_ARCHITECTURE"
		exit 1
	}
}

$hotfix = check-hotfix
if ($hotfix) {
	Write-Host "Exiting, this system already has a patch: $hotfix"
	exit 0
}

$dir = "C:\temp\sambacry-patch\"

try {
	Write-Host "Creating working directory $dir..."
	New-Item $dir -type directory -force | Out-Null
	Set-Location $dir
} catch {
	throw "Failed to create working directory: " + $_.Exception
}

try {
	Write-Host "Downloading $link..."
	# get filename (split array by slash and get last element)
	$split = $link.split('/')
	$filename = $split[($split.length - 1)]
	(new-object System.Net.WebClient).DownloadFile($link, $dir + $filename)
} catch {
	#throw "Failed to download: " + $_.Exception
}

# Quick reset of Windows Update
$services = $("wuauserv", "cryptsvc", "bits", "msiserver")
ForEach-Object -InputObject $services { Stop-Service $_ -Force }
Remove-Item "C:\Windows\SoftwareDistribution\*" -Recurse -Force
Remove-Item "C:\Windows\System32\catroot2\*" -Recurse -Force
ForEach-Object -InputObject $services { Start-Service $_ }

# Remove any old log file
Remove-Item $dir"log.txt" -Force
Remove-Item $dir"wusa.etl" -Force

# exe vs msu
if ($filename.Split('.')[($filename.Split('.').length - 1)] -eq 'msu') {
	# MSU installer
	# In case it's already running, stop it. Don't really care if this succeeds or fails.
	Write-Host "Stopping any already-running wusa.exe..."
	taskkill /im "wusa.exe" /f
	
	try {
		Write-Host "Running installer..."
		Start-Process -FilePath wusa.exe -ArgumentList @("$dir$filename", "/quiet", "/norestart", "/log:$dir\wusa.etl") -Wait
	} catch {
		throw "Failed to install patch: " + $_.Exception
	}
} else {
	# EXE installer (Windows XP/Server 2003)
	Start-Process -FilePath $dir$filename -ArgumentList @("/quiet", "/norestart", "/log:${dir}log.txt") -Wait
}

Write-Host "Installer exited. Checking to verify hotfix successully installed..."

$hotfix = check-hotfix
if ($hotfix) {
	Write-Host "Success! Hotfix installed: $hotfix"
	exit 0
} else {
	Write-Host "Installer exited, but required hotfix not installed! Will try to print event log."
	Write-Host "You may just want to install the patch in $dir manually."
	Get-WinEvent -Path $dir"wusa.etl" -Oldest | Format-Table TimeCreated, Id, Message
	exit 1
}