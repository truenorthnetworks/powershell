# Install Windows Management Framework 3.0
# wmassingham@truenorthnetworks.com, 2018-03-20

Write-Host "Device: $env:computername"

$arch = $ENV:PROCESSOR_ARCHITECTURE
$os = (Get-WmiObject -class Win32_OperatingSystem).caption

#Write-Host "Detecting operating system..."

#""     { $link = ""; break; }

switch ($arch) {
	"x86" {
		Write-Host "Operating system: $os 32-bit"
		switch -wildcard ($os) {
			"Microsoft*2008*"       { $link = "https://download.microsoft.com/download/E/7/6/E76850B8-DA6E-4FF5-8CCE-A24FC513FD16/Windows6.0-KB2506146-x86.msu"; break; }
			"Microsoft*7*"          { $link = "https://download.microsoft.com/download/E/7/6/E76850B8-DA6E-4FF5-8CCE-A24FC513FD16/Windows6.1-KB2506143-x86.msu"; break; }
			default { throw "Unsupported OS: $os" }
		}
		break;
	}
	"AMD64" {
		Write-Host "Operating system: $os 64-bit"
		switch -wildcard ($os) {
			"Microsoft*2008*R2*"    { $link = "https://download.microsoft.com/download/E/7/6/E76850B8-DA6E-4FF5-8CCE-A24FC513FD16/Windows6.1-KB2506143-x64.msu"; break; }
			"Microsoft*2008*"       { $link = "https://download.microsoft.com/download/E/7/6/E76850B8-DA6E-4FF5-8CCE-A24FC513FD16/Windows6.0-KB2506146-x64.msu"; break; }
			"Microsoft*7*"          { $link = "https://download.microsoft.com/download/E/7/6/E76850B8-DA6E-4FF5-8CCE-A24FC513FD16/Windows6.1-KB2506143-x64.msu"; break; }
			default { throw "Unsupported OS: $os" }
		}
		break;
	}
	default {
		throw "Unsupported architecture: $ENV:PROCESSOR_ARCHITECTURE"
		exit 1
	}
}

$dir = "C:\temp\KB40113\"

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
	throw "Failed to download: " + $_.Exception
}

# Quick reset of Windows Update
<#
$services = $("wuauserv", "cryptsvc", "bits", "msiserver")
ForEach-Object -InputObject $services { Stop-Service $_ -Force }
Remove-Item "C:\Windows\SoftwareDistribution\*" -Recurse -Force
Remove-Item "C:\Windows\System32\catroot2\*" -Recurse -Force
ForEach-Object -InputObject $services { Start-Service $_ }
#>

# Remove any old log file
Remove-Item $dir"log.txt" -Force -ErrorAction SilentlyContinue
Remove-Item $dir"wusa.etl" -Force -ErrorAction SilentlyContinue

# exe vs msu
#if ($filename.Split('.')[($filename.Split('.').length - 1)] -eq 'msu') {
	# MSU installer
	# In case it's already running, stop it. Don't really care if this succeeds or fails.
	Write-Host "Stopping any already-running wusa.exe..."
	Stop-Process -Name "wusa" -Force -ErrorAction SilentlyContinue
	
	try {
		Write-Host "Running installer..."
		Start-Process -FilePath wusa.exe -ArgumentList @("$dir$filename","/quiet","/norestart","/log:$dir\wusa.etl") -Wait
	} catch {
		throw "Failed to install patch: " + $_.Exception
	}
#} else {
# 	# EXE installer (Windows XP/Server 2003)
# 	Start-Process -FilePath $dir$filename -ArgumentList @("/quiet","/norestart","/log:${dir}log.txt") -Wait
# }

if (get-hotfix kb2506143,kb2506146) {
	Write-Host "Success! WMF 3.0 appears to have been installed properly. Printing WUSA log for your convenience."
	exit 0
} else {
	Write-Host "Installer exited, but required hotfix not installed! Printing WUSA log for your convenience."
	Write-Host "You may just want to install the patch in $dir manually."
	exit 1
}
Get-WinEvent -Path $dir"wusa.etl" -Oldest | Format-Table TimeCreated,Id,Message
