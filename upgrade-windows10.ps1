# 2019-02-22 wmassingham@truenorthnetworks.com
# Downloads and runs setup from a Windows 10 ISO

# location to save the iso
$dir = "c:\windows\temp"

# url to download
$url = ""

# filename of iso
$iso = Split-Path -Path $url -Leaf

# remove any previous isos
Remove-Item "$dir\Win10_*.iso" -Force -ErrorAction SilentlyContinue

# download the iso
try {
	Write-Host "Downloading ISO"
	$WebClient = New-Object System.Net.WebClient
	$WebClient.DownloadFile("$url", "$dir\$iso")
} catch {
	Write-Error ("Failed to download ISO: " + $_.Exception.Message)
	Write-Error ("InnerException: " + $_.Exception.InnerExceptionMessage)
	exit 1
}

# mount the iso
try {
	Write-Host "Mounting $dir\$iso"
	$mount = Mount-DiskImage "$dir\$iso" -PassThru
	$letter = ($mount | Get-Volume).DriveLetter
} catch {
	Write-Error ("Failed to mount ISO: " + $_.Exception.Message)
	exit 1
}

# enable windows update
try {
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "DisableWindowsUpdateAccess" -Value 0 -Force
} catch {
	Write-Error ("Failed to enable Windows Update: " + $_.Exception.Message)
	exit 1
}

# run setup
try {
	if ($reboot -eq "true") {
		$params = "/auto upgrade /quiet /showoobe none"
	} else {
		$params = "/auto upgrade /quiet /showoobe none /noreboot"
	}
	Write-Host "Starting ${letter}:\setup.exe, params: $params"
	Start-Process "${letter}:\setup.exe" -ArgumentList $params
} catch {
	Write-Error ("Failed to execute installer: " + $_.Exception.Message)
	exit 1
}
