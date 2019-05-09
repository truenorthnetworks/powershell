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
			"Microsoft*Embedded*"   { $link = "http://download.windowsupdate.com/c/csa/csa/secu/2017/02/windowsxp-kb4012598-x86-embedded-custom-enu_8f2c266f83a7e1b100ddb9acd4a6a3ab5ecd4059.exe";  break; }
			"Microsoft*2003*"       { $link = "http://download.windowsupdate.com/c/csa/csa/secu/2017/02/windowsserver2003-kb4012598-x86-custom-enu_f617caf6e7ee6f43abe4b386cb1d26b3318693cf.exe";   break; }
			"Microsoft*2008*"       { $link = "http://download.windowsupdate.com/d/msdownload/update/software/secu/2017/02/windows6.0-kb4012598-x86_13e9b3d77ba5599764c296075a796c16a85c745c.msu";  break; }
			"Microsoft*XP*"         { $link = "http://download.windowsupdate.com/d/csa/csa/secu/2017/02/windowsxp-kb4012598-x86-custom-enu_eceb7d5023bbb23c0dc633e46b9c2f14fa6ee9dd.exe";           break; }
			"Microsoft*7*"          { $link = "http://download.windowsupdate.com/d/msdownload/update/software/secu/2017/02/windows6.1-kb4012212-x86_6bb04d3971bb58ae4bac44219e7169812914df3f.msu";  break; }
			"Microsoft*8.1*"        { $link = "http://download.windowsupdate.com/c/msdownload/update/software/secu/2017/02/windows8.1-kb4012213-x86_e118939b397bc983971c88d9c9ecc8cbec471b05.msu";  break; }
			"Microsoft*8*"          { $link = "http://download.windowsupdate.com/c/msdownload/update/software/secu/2017/05/windows8-rt-kb4012598-x86_a0f1c953a24dd042acc540c59b339f55fb18f594.msu"; break; }
			"Microsoft Windows 10*" {
				$build = (Get-CimInstance Win32_OperatingSystem).buildnumber
				switch ($build) {
					"10240" { $link = "http://download.windowsupdate.com/c/msdownload/update/software/secu/2017/03/windows10.0-kb4012606-x86_8c19e23de2ff92919d3fac069619e4a8e8d3492e.msu";       break; } # 1507
					"10586" { $link = "http://download.windowsupdate.com/c/msdownload/update/software/secu/2017/03/windows10.0-kb4013198-x86_f997cfd9b59310d274329250f14502c3b97329d5.msu";       break; } # 1511
					"14393" { $link = "http://download.windowsupdate.com/c/msdownload/update/software/secu/2017/03/windows10.0-kb4013429-x86_delta_13d776b4b814fcc39e483713ad012070466a950b.msu"; break; } # 1607
					default { throw "Unsupported Win10 build: $build"; break; }
				}
				break;
			}
			default { throw "Unsupported OS: $os" }
		}
		break;
	}
	"AMD64" {
		Write-Host "Operating system: $os 64-bit"
		switch -wildcard ($os) {
			"Microsoft*2003*"       { $link = "http://download.windowsupdate.com/d/csa/csa/secu/2017/02/windowsserver2003-kb4012598-x64-custom-enu_f24d8723f246145524b9030e4752c96430981211.exe";   break; }
			"Microsoft*2008*R2*"    { $link = "http://download.windowsupdate.com/d/msdownload/update/software/secu/2017/02/windows6.1-kb4012212-x64_2decefaa02e2058dcd965702509a992d8c4e92b3.msu";  break; }
			"Microsoft*2008*"       { $link = "http://download.windowsupdate.com/d/msdownload/update/software/secu/2017/02/windows6.0-kb4012598-x64_6a186ba2b2b98b2144b50f88baf33a5fa53b5d76.msu";  break; }
			"Microsoft*2012*R2*"    { $link = "http://download.windowsupdate.com/c/msdownload/update/software/secu/2017/02/windows8.1-kb4012213-x64_5b24b9ca5a123a844ed793e0f2be974148520349.msu";  break; }
			"Microsoft*2012*"       { $link = "http://download.windowsupdate.com/c/msdownload/update/software/secu/2017/02/windows8-rt-kb4012214-x64_b14951d29cb4fd880948f5204d54721e64c9942b.msu"; break; }
			"Microsoft*XP*"         { $link = "http://download.windowsupdate.com/d/csa/csa/secu/2017/02/windowsserver2003-kb4012598-x64-custom-enu_f24d8723f246145524b9030e4752c96430981211.exe";   break; }
			"Microsoft*7*"          { $link = "http://download.windowsupdate.com/d/msdownload/update/software/secu/2017/02/windows6.1-kb4012212-x64_2decefaa02e2058dcd965702509a992d8c4e92b3.msu";  break; }
			"Microsoft*8.1*"        { $link = "http://download.windowsupdate.com/c/msdownload/update/software/secu/2017/02/windows8.1-kb4012213-x64_5b24b9ca5a123a844ed793e0f2be974148520349.msu";  break; }
			"Microsoft*8*"          { $link = "http://download.windowsupdate.com/c/msdownload/update/software/secu/2017/05/windows8-rt-kb4012598-x64_f05841d2e94197c2dca4457f1b895e8f632b7f8e.msu"; break; }
			"Microsoft Windows 10*" {
				$build = (Get-CimInstance Win32_OperatingSystem).buildnumber
				switch ($build) {
					"10240" { $link = "http://download.windowsupdate.com/c/msdownload/update/software/secu/2017/03/windows10.0-kb4012606-x64_e805b81ee08c3bb0a8ab2c5ce6be5b35127f8773.msu";       break; } # 1507
					"10586" { $link = "http://download.windowsupdate.com/c/msdownload/update/software/secu/2017/03/windows10.0-kb4013198-x64_7b16621bdc40cb512b7a3a51dd0d30592ab02f08.msu";       break; } # 1511
					"14393" { $link = "http://download.windowsupdate.com/c/msdownload/update/software/secu/2017/03/windows10.0-kb4013429-x64_delta_24521980a64972e99692997216f9d2cf73803b37.msu"; break; } # 1607
					default { throw "Unsupported Win10 build: $build"; break; }
				}
				break;
			}
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

$dir = "C:\temp\wannacry-patch\"

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
		Start-Process -FilePath wusa.exe -ArgumentList @("$dir$filename","/quiet","/norestart","/log:$dir\wusa.etl") -Wait
	} catch {
		throw "Failed to install patch: " + $_.Exception
	}
} else {
	# EXE installer (Windows XP/Server 2003)
	Start-Process -FilePath $dir$filename -ArgumentList @("/quiet","/norestart","/log:${dir}log.txt") -Wait
}

Write-Host "Installer exited. Checking to verify hotfix successully installed..."

$hotfix = check-hotfix
if ($hotfix) {
	Write-Host "Success! Hotfix installed: $hotfix"
	exit 0
} else {
	Write-Host "Installer exited, but required hotfix not installed! Will try to print event log."
	Write-Host "You may just want to install the patch in $dir manually."
	Get-WinEvent -Path $dir"wusa.etl" -Oldest | Format-Table TimeCreated,Id,Message
	exit 1
}
